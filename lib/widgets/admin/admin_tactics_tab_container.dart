import 'package:flutter/material.dart';
import 'package:vsm_app/models/event_model.dart';
import 'package:vsm_app/models/prensentPlayers.dart';
import 'package:vsm_app/widgets/player/PlayerTacticalFieldWidget.dart';
import 'package:vsm_app/widgets/coach/squad_tab_widget.dart'; // Ou ton widget de coéquipiers/membres

class AdminTacticsTabContainer extends StatelessWidget {
  final EventModel event;
  final String selectedFormation;
  final Map<String, PresentPlayer> assignedPlayers;
  final List<PresentPlayer> substitutePlayers;
  final PresentPlayer? connectedPlayer;

  const AdminTacticsTabContainer({
    super.key,
    required this.event,
    required this.selectedFormation,
    required this.assignedPlayers,
    required this.substitutePlayers,
    this.connectedPlayer,
  });

  @override
  Widget build(BuildContext context) {
    const Color greenPrimary = Color(0xFF1E5235);
    const Color goldAccent = Color(0xFFD4AF37);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Barre de sous-onglets élégante
          Container(
            color: greenPrimary.withOpacity(0.9),
            child: const TabBar(
              indicatorColor: goldAccent,
              indicatorWeight: 3.0,
              labelColor: goldAccent,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              tabs: [
                Tab(
                  icon: Icon(Icons.sports_soccer, size: 18),
                  text: "Tactique",
                ),
                Tab(
                  icon: Icon(Icons.groups, size: 18),
                  text: "Coéquipiers",
                ),
              ],
            ),
          ),
          // Contenu des sous-onglets
          Expanded(
            child: TabBarView(
              children: [
                // 1. Vue Tactique (Terrain / Composition)
                PlayerTacticsTabWidget(
                  event: event,
                  selectedFormation: selectedFormation,
                  assignedPlayers: assignedPlayers,
                  substitutePlayers: substitutePlayers,
                  connectedPlayer: connectedPlayer,
                ),
                // 2. Vue Coéquipiers (Membres / Présences)
                SquadTabWidget(event: event),
              ],
            ),
          ),
        ],
      ),
    );
  }
}