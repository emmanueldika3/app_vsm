import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:vsm_app/models/prensentPlayers.dart';

class PresentPlayersBench extends StatefulWidget {
  final int eventId;
  final String token;
  final Function(PresentPlayer player)? onPlayerSelected;
  final List<PresentPlayer> assignedPlayers;

  const PresentPlayersBench({
    Key? key,
    required this.eventId,
    required this.token,
    this.onPlayerSelected,
    required this.assignedPlayers,
  }) : super(key: key);

  @override
  _PresentPlayersBenchState createState() => _PresentPlayersBenchState();
}

class _PresentPlayersBenchState extends State<PresentPlayersBench> {
  List<PresentPlayer> presentPlayers = [];
  bool isLoading = true;

  // Couleurs Charte VSM FC
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color greenDark = Color(0xFF0A1E13);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color bordeauxRed = Color(0xFF6B1D2F);

  @override
  void initState() {
    super.initState();
    if (widget.eventId > 0) {
      _fetchPresentPlayers();
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void didUpdateWidget(covariant PresentPlayersBench oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eventId != widget.eventId && widget.eventId > 0) {
      _fetchPresentPlayers();
    }
  }

  String _getApiBaseUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.52.90.145:8000/api';
    } else {
      return 'http://127.0.0.1:8000/api';
    }
  }

  Future<void> _fetchPresentPlayers() async {
    setState(() => isLoading = true);
    final baseUrl = _getApiBaseUrl();
    final url = '$baseUrl/events/${widget.eventId}/presents';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> playersJson = data['data'] ?? [];
        setState(() {
          presentPlayers = playersJson
              .map((json) => PresentPlayer.fromJson(json))
              .toList();
          isLoading = false;
        });
      } else {
        print(
          "Erreur API (Banc) : Code ${response.statusCode} - ${response.body}",
        );
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Erreur réseau (Banc) : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // FILTRAGE : On exclut les joueurs qui sont déjà placés sur le terrain
    final availablePlayers = presentPlayers.where((player) {
      return !widget.assignedPlayers.any(
        (assigned) => assigned.id == player.id,
      );
    }).toList();

    int totalPresentCount = presentPlayers.length;
    int remainingOnBench = availablePlayers.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête compact avec le titre du banc et le compteur dynamique
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Banc de touche",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: greenDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: greenPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Disponibles : $remainingOnBench / $totalPresentCount",
                  style: const TextStyle(
                    color: goldAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 60, // Hauteur réduite pour optimiser l'espace du terrain
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : availablePlayers.isEmpty
              ? const Center(
                  child: Text(
                    "Tous les joueurs sont sur le terrain ou absents.",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: availablePlayers.length,
                  itemBuilder: (context, index) {
                    final player = availablePlayers[index];

                    return Draggable<PresentPlayer>(
                      data: player,
                      feedback: Material(
                        color: Colors.transparent,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: goldAccent,
                          child: Text(
                            player.number,
                            style: const TextStyle(
                              color: greenDark,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      child: Container(
                        width: 55, // Largeur de carte réduite
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: greenPrimary.withOpacity(0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 13, // Avatar plus petit
                              backgroundColor: bordeauxRed,
                              child: Text(
                                player.number,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              player.name.split(" ").last,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
