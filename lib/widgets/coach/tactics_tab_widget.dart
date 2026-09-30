import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tactical_field_widget.dart';
import 'presentplayersBench.dart';
import 'package:vsm_app/models/prensentPlayers.dart';
import 'package:vsm_app/provider/coach/event_provider.dart';

class TacticalTabWidget extends StatefulWidget {
  const TacticalTabWidget({Key? key}) : super(key: key);

  @override
  State<TacticalTabWidget> createState() => _TacticalTabWidgetState();
}

class _TacticalTabWidgetState extends State<TacticalTabWidget> {
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color greenDark = Color(0xFF0A1E13);
  static const Color goldAccent = Color(0xFFD4AF37);

  String _selectedFormation = "4-3-3";
  final List<String> _formations = [
    "4-3-3",
    "4-4-2",
    "4-5-1",
    "3-5-2",
    "4-2-3-1",
  ];

  // État centralisé des joueurs positionnés sur le terrain
  final Map<String, PresentPlayer> _assignedPlayers = {};

  // Changement de système intelligent sans perte totale des joueurs
  void _handleFormationChange(String? newFormation) {
    if (newFormation == null || newFormation == _selectedFormation) return;

    setState(() {
      _selectedFormation = newFormation;

      Map<String, List<String>> validPositions = {
        "4-3-3": [
          "GK",
          "LB",
          "CB1",
          "CB2",
          "RB",
          "LCM",
          "CM",
          "RCM",
          "LW",
          "ST",
          "RW",
        ],
        "4-4-2": [
          "GK",
          "LB",
          "CB1",
          "CB2",
          "RB",
          "LM",
          "CM1",
          "CM2",
          "RM",
          "ST1",
          "ST2",
        ],
        "3-5-2": [
          "GK",
          "CB1",
          "CB2",
          "CB3",
          "LWB",
          "LCM",
          "CM",
          "RCM",
          "RWB",
          "ST1",
          "ST2",
        ],
        "4-5-1": [
          "GK",
          "LB",
          "CB1",
          "CB2",
          "RB",
          "LM",
          "LCM",
          "CM",
          "RCM",
          "RM",
          "ST",
        ],
        "4-2-3-1": [
          "GK",
          "LB",
          "CB1",
          "CB2",
          "RB",
          "CDM1",
          "CDM2",
          "LAM",
          "CAM",
          "RAM",
          "ST",
        ],
      };

      List<String> newAllowedPos =
          validPositions[newFormation] ?? validPositions["4-3-3"]!;
      Map<String, PresentPlayer> updatedAssignments = {};
      List<PresentPlayer> unassignedOrMovedPlayers = [];

      _assignedPlayers.forEach((pos, player) {
        if (newAllowedPos.contains(pos)) {
          updatedAssignments[pos] = player;
        } else {
          unassignedOrMovedPlayers.add(player);
        }
      });

      int playerIndex = 0;
      for (String pos in newAllowedPos) {
        if (!updatedAssignments.containsKey(pos) &&
            playerIndex < unassignedOrMovedPlayers.length) {
          updatedAssignments[pos] = unassignedOrMovedPlayers[playerIndex];
          playerIndex++;
        }
      }

      _assignedPlayers.clear();
      _assignedPlayers.addAll(updatedAssignments);
    });
  }

  // Fonction de Cleanup : ramène tous les pions au banc d'un clic
  void _clearField() {
    setState(() {
      _assignedPlayers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final eventId = eventProvider.upcomingEvent?.id ?? 0;
    const String token = "";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.sports_soccer, color: goldAccent, size: 20),
                  const SizedBox(width: 6),
                  const Text(
                    "Gestion Tactique",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: greenDark,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Bouton Cleanup (Interrupteur / Reset rapide)
                  Tooltip(
                    message: "Renvoyer tous les joueurs au banc",
                    child: InkWell(
                      onTap: _clearField,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.redAccent,
                            width: 0.8,
                          ),
                        ),
                        child: const Icon(
                          Icons.cleaning_services_rounded,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Dropdown Formations
                  Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: greenPrimary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: goldAccent, width: 0.8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedFormation,
                      dropdownColor: greenDark,
                      underline: const SizedBox(),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: goldAccent,
                        size: 18,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      items: _formations.map((String formation) {
                        return DropdownMenuItem<String>(
                          value: formation,
                          child: Text(formation),
                        );
                      }).toList(),
                      onChanged: _handleFormationChange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // TERRAIN
          Expanded(
            child: SingleChildScrollView(
              child: TacticalFieldWidget(
                selectedFormation: _selectedFormation,
                assignedPlayers: _assignedPlayers,
                onPlayerAssigned: (posKey, player) {
                  setState(() {
                    String? previousKey;
                    _assignedPlayers.forEach((key, val) {
                      if (val.id == player.id) {
                        previousKey = key;
                      }
                    });

                    PresentPlayer? targetPlayer = _assignedPlayers[posKey];

                    if (previousKey != null) {
                      _assignedPlayers.remove(previousKey);
                    }

                    if (targetPlayer != null && previousKey != null) {
                      _assignedPlayers[previousKey!] = targetPlayer;
                    }

                    _assignedPlayers[posKey] = player;
                  });
                },
                onPlayerRemoved: (posKey) {
                  setState(() {
                    _assignedPlayers.remove(posKey);
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 6),

          // BANC DE TOUCHE
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: greenPrimary.withOpacity(0.2)),
            ),
            child: PresentPlayersBench(
              eventId: eventId,
              token: token,
              assignedPlayers: _assignedPlayers.values.toList(),
            ),
          ),
        ],
      ),
    );
  }
}
