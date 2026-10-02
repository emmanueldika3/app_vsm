import 'package:flutter/foundation.dart'; // Pour kIsWeb
import 'dart:io'; // Pour Platform.isAndroid
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vsm_app/models/squad_member.dart';
import 'package:vsm_app/widgets/coach/member_details_bottom_sheet.dart';
import 'package:vsm_app/widgets/coach/squad_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SquadEffectifWidget extends StatefulWidget {
  const SquadEffectifWidget({super.key});

  @override
  State<SquadEffectifWidget> createState() => _SquadEffectifWidgetState();
}

class _SquadEffectifWidgetState extends State<SquadEffectifWidget> {
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color bordeauxRed = Color(0xFF6B1D2F);

  late Future<List<SquadMember>> _squadFuture;
  int? _currentEventId; // Stockera l'ID dynamique de l'événement upcoming

  @override
  void initState() {
    super.initState();
    _squadFuture = _fetchUpcomingEventAndPresences();
  }

  /// Détermination dynamique de l'URL de base selon la plateforme
  String _getApiBaseUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.52.90.145:8000/api';
    } else {
      return 'http://127.0.0.1:8000/api';
    }
  }

  /// 1. Récupère l'événement /upcoming, puis 2. Récupère ses présences[cite: 3]
  Future<List<SquadMember>> _fetchUpcomingEventAndPresences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = _getApiBaseUrl();

      // Étape A : Appel de l'endpoint /events/upcoming[cite: 3]
      final upcomingResponse = await http.get(
        Uri.parse('$baseUrl/events/upcoming'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (upcomingResponse.statusCode != 200) {
        throw Exception(
          "Impossible de récupérer l'événement à venir (Code: ${upcomingResponse.statusCode})",
        );
      }

      final eventData = json.decode(upcomingResponse.body);

      // Extraction sécurisée de l'ID[cite: 3]
      final int eventId = eventData['id'] ?? eventData['data']?['id'];

      setState(() {
        _currentEventId = eventId;
      });

      // Étape B : Appel de l'endpoint des présences avec l'ID dynamique[cite: 3]
      final presencesResponse = await http.get(
        Uri.parse('$baseUrl/events/$eventId/presences'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (presencesResponse.statusCode == 200) {
        final decodedData = json.decode(presencesResponse.body);

        if (decodedData is List) {
          return decodedData
              .map((jsonItem) => SquadMember.fromJson(jsonItem))
              .toList();
        } else if (decodedData is Map<String, dynamic>) {
          final listData = decodedData['users'] ?? decodedData['data'] ?? [];
          if (listData is List) {
            return listData
                .map((jsonItem) => SquadMember.fromJson(jsonItem))
                .toList();
          }
        }
        return [];
      } else {
        throw Exception(
          "Erreur serveur lors de la récupération des présences.",
        );
      }
    } catch (e) {
      throw Exception("Erreur : $e");
    }
  }

  /// Permet au coach de modifier le statut d'un membre (ex: passer un incertain en présent/banc ou absent)[cite: 3]
  Future<void> _updateMemberStatus(SquadMember member, String newStatus) async {
    if (_currentEventId == null) return;

    setState(() {
      member.status = newStatus;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = _getApiBaseUrl();

      // Appel de l'API Laravel pour enregistrer le changement par le coach[cite: 3]
      final response = await http.post(
        Uri.parse('$baseUrl/events/$_currentEventId/presences/${member.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode != 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur lors de la mise à jour du statut."),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur de connexion : $e")));
    }
  }

  /// Affichage de la fiche de détail au clic sur un membre[cite: 3]
  void _showMemberDetails(BuildContext context, SquadMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MemberDetailsBottomSheet(member: member),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SquadMember>>(
      future: _squadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30.0),
              child: CircularProgressIndicator(color: greenPrimary),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Erreur : ${snapshot.error}",
                style: const TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final members = snapshot.data ?? [];

        // Séparation des membres selon les statuts
        final presents = members.where((m) => m.status == "present").toList();
        final absents = members.where((m) => m.status == "absent").toList();
        final uncertains = members
            .where((m) => m.status == "uncertain")
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section des Incertains (le coach peut modifier leur statut vers present ou absent)
            SquadSection(
              title: "Incertains",
              color: Colors.orange,
              members: uncertains,
              isUncertain: true,
              onMemberTap: (member) => _showMemberDetails(context, member),
              onStatusChanged: (member, newStatus) =>
                  _updateMemberStatus(member, newStatus),
            ),
            const SizedBox(height: 16),

            // Section des Présents (disponibles pour le banc / l'événement)
            SquadSection(
              title: "Présents",
              color: greenPrimary,
              members: presents,
              onMemberTap: (member) => _showMemberDetails(context, member),
            ),
            const SizedBox(height: 16),

            // Section des Absents
            SquadSection(
              title: "Absents",
              color: bordeauxRed,
              members: absents,
              onMemberTap: (member) => _showMemberDetails(context, member),
            ),
          ],
        );
      },
    );
  }
}
