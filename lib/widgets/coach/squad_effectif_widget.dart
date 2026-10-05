import 'package:flutter/foundation.dart';
import 'dart:io';
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
  int? _currentEventId;

  @override
  void initState() {
    super.initState();
    _squadFuture = _fetchUpcomingEventAndPresences();
  }

  String _getApiBaseUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else if (Platform.isAndroid) {
      // Utilisez 10.0.2.2 pour l'émulateur Android par défaut, ou votre IP fixe
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://127.0.0.1:8000/api';
    }
  }

  Future<List<SquadMember>> _fetchUpcomingEventAndPresences() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final baseUrl = _getApiBaseUrl();

    // 1. Récupération de l'événement upcoming
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
        "Erreur HTTP ${upcomingResponse.statusCode} sur /events/upcoming",
      );
    }

    final jsonResponse = json.decode(upcomingResponse.body);
    final eventObj = jsonResponse['data'];

    if (eventObj == null || eventObj['id'] == null) {
      return []; // Aucun événement à venir
    }

    final int eventId = eventObj['id'];
    setState(() {
      _currentEventId = eventId;
    });

    // 2. Récupération des présences de cet événement
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
      final List listData = decodedData['data'] ?? [];

      return listData
          .map((jsonItem) => SquadMember.fromJson(jsonItem))
          .toList();
    } else {
      throw Exception("Erreur lors du chargement des présences.");
    }
  }

  Future<void> _updateUncertainStatus(
    SquadMember member,
    String newStatus,
  ) async {
    if (_currentEventId == null) return;

    setState(() {
      member.status = newStatus;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = _getApiBaseUrl();

      await http.post(
        Uri.parse('$baseUrl/events/$_currentEventId/presences/${member.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': newStatus}),
      );
    } catch (e) {
      debugPrint("Erreur mise à jour statut : $e");
    }
  }

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
                "Impossible de charger l'effectif.\n\nDétails : ${snapshot.error}",
                style: const TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final members = snapshot.data ?? [];

        if (members.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Aucun événement à venir ou aucune présence enregistrée.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final presents = members.where((m) => m.status == "present").toList();
        final absents = members.where((m) => m.status == "absent").toList();
        final uncertains = members
            .where((m) => m.status == "uncertain")
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SquadSection(
              title: "Incertains",
              color: Colors.orange,
              members: uncertains,
              isUncertain: true,
              onMemberTap: (member) => _showMemberDetails(context, member),
              onStatusChanged: (member, newStatus) =>
                  _updateUncertainStatus(member, newStatus),
            ),
            const SizedBox(height: 16),
            SquadSection(
              title: "Présents",
              color: greenPrimary,
              members: presents,
              onMemberTap: (member) => _showMemberDetails(context, member),
            ),
            const SizedBox(height: 16),
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
