import 'package:flutter/material.dart';
import 'package:vsm_app/models/prensentPlayers.dart';

class TacticalFieldWidget extends StatelessWidget {
  final String selectedFormation;
  final Map<String, PresentPlayer> assignedPlayers;
  final Function(String posKey, PresentPlayer player) onPlayerAssigned;
  final Function(String posKey)? onPlayerRemoved;

  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color greenDark = Color(0xFF0A1E13);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color bordeauxRed = Color(0xFF6B1D2F);

  const TacticalFieldWidget({
    Key? key,
    required this.selectedFormation,
    required this.assignedPlayers,
    required this.onPlayerAssigned,
    this.onPlayerRemoved,
  }) : super(key: key);

  List<Map<String, dynamic>> _getPositionsForFormation(String formation) {
    switch (formation) {
      case "4-3-3":
        return [
          {"pos": "GK", "top": 0.85, "left": 0.45},
          {"pos": "LB", "top": 0.65, "left": 0.12},
          {"pos": "CB1", "top": 0.68, "left": 0.35},
          {"pos": "CB2", "top": 0.68, "left": 0.58},
          {"pos": "RB", "top": 0.65, "left": 0.80},
          {"pos": "LCM", "top": 0.45, "left": 0.28},
          {"pos": "CM", "top": 0.48, "left": 0.45},
          {"pos": "RCM", "top": 0.45, "left": 0.62},
          {"pos": "LW", "top": 0.20, "left": 0.15},
          {"pos": "ST", "top": 0.15, "left": 0.45},
          {"pos": "RW", "top": 0.20, "left": 0.75},
        ];
      case "4-4-2":
        return [
          {"pos": "GK", "top": 0.85, "left": 0.45},
          {"pos": "LB", "top": 0.65, "left": 0.12},
          {"pos": "CB1", "top": 0.68, "left": 0.35},
          {"pos": "CB2", "top": 0.68, "left": 0.58},
          {"pos": "RB", "top": 0.65, "left": 0.80},
          {"pos": "LM", "top": 0.42, "left": 0.15},
          {"pos": "CM1", "top": 0.45, "left": 0.36},
          {"pos": "CM2", "top": 0.45, "left": 0.57},
          {"pos": "RM", "top": 0.42, "left": 0.75},
          {"pos": "ST1", "top": 0.18, "left": 0.35},
          {"pos": "ST2", "top": 0.18, "left": 0.58},
        ];
      case "3-5-2":
        return [
          {"pos": "GK", "top": 0.85, "left": 0.45},
          {"pos": "CB1", "top": 0.68, "left": 0.25},
          {"pos": "CB2", "top": 0.70, "left": 0.45},
          {"pos": "CB3", "top": 0.68, "left": 0.65},
          {"pos": "LWB", "top": 0.45, "left": 0.12},
          {"pos": "LCM", "top": 0.48, "left": 0.32},
          {"pos": "CM", "top": 0.42, "left": 0.45},
          {"pos": "RCM", "top": 0.48, "left": 0.58},
          {"pos": "RWB", "top": 0.45, "left": 0.80},
          {"pos": "ST1", "top": 0.18, "left": 0.38},
          {"pos": "ST2", "top": 0.18, "left": 0.55},
        ];
      default:
        return [
          {"pos": "GK", "top": 0.85, "left": 0.45},
          {"pos": "LB", "top": 0.65, "left": 0.12},
          {"pos": "CB1", "top": 0.68, "left": 0.35},
          {"pos": "CB2", "top": 0.68, "left": 0.58},
          {"pos": "RB", "top": 0.65, "left": 0.80},
          {"pos": "LCM", "top": 0.45, "left": 0.28},
          {"pos": "CM", "top": 0.48, "left": 0.45},
          {"pos": "RCM", "top": 0.45, "left": 0.62},
          {"pos": "LW", "top": 0.20, "left": 0.15},
          {"pos": "ST", "top": 0.15, "left": 0.45},
          {"pos": "RW", "top": 0.20, "left": 0.75},
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPositions = _getPositionsForFormation(selectedFormation);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double fieldWidth = constraints.maxWidth;
        const double fieldHeight = 500.0;

        return Container(
          height: fieldHeight,
          width: fieldWidth,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [greenPrimary, greenDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: goldAccent, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: fieldWidth / 2 - 40,
                child: Container(
                  width: 80,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: goldAccent.withOpacity(0.7),
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: fieldWidth,
                  height: 2,
                  color: goldAccent.withOpacity(0.4),
                ),
              ),
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: goldAccent.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: goldAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: fieldWidth / 2 - 40,
                child: Container(
                  width: 80,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: goldAccent.withOpacity(0.7),
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                ),
              ),
              for (var posData in currentPositions)
                _buildTacticalSlot(
                  posKey: posData["pos"],
                  top: posData["top"] * fieldHeight,
                  left: posData["left"] * fieldWidth,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTacticalSlot({
    required String posKey,
    required double top,
    required double left,
  }) {
    final assignedPlayer = assignedPlayers[posKey];

    return Positioned(
      top: top - 26,
      left: left - 28,
      child: DragTarget<PresentPlayer>(
        onAccept: (receivedPlayer) {
          onPlayerAssigned(posKey, receivedPlayer);
        },
        builder: (context, candidateData, rejectedData) {
          Widget playerWidget = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: assignedPlayer != null
                          ? (assignedPlayer.number == "7"
                                ? goldAccent
                                : bordeauxRed)
                          : Colors.black45,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: candidateData.isNotEmpty
                            ? Colors.yellow
                            : Colors.white,
                        width: assignedPlayer?.number == "7" ? 2.5 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        assignedPlayer != null ? assignedPlayer.number : posKey,
                        style: TextStyle(
                          color:
                              assignedPlayer != null &&
                                  assignedPlayer.number == "7"
                              ? greenDark
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: assignedPlayer != null ? 13 : 11,
                        ),
                      ),
                    ),
                  ),
                  // Petite croix/bouton de suppression rapide pour renvoyer au banc
                  if (assignedPlayer != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          if (onPlayerRemoved != null) {
                            onPlayerRemoved!(posKey);
                          }
                        },
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  assignedPlayer != null
                      ? assignedPlayer.name.split(" ").last
                      : posKey,
                  style: TextStyle(
                    color: assignedPlayer?.number == "7"
                        ? goldAccent
                        : Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );

          if (assignedPlayer != null) {
            return GestureDetector(
              onDoubleTap: () {
                // Double tap pour renvoyer au banc instantanément
                if (onPlayerRemoved != null) {
                  onPlayerRemoved!(posKey);
                }
              },
              onLongPress: () {
                // Appui long alternatif pour renvoyer au banc
                if (onPlayerRemoved != null) {
                  onPlayerRemoved!(posKey);
                }
              },
              child: Draggable<PresentPlayer>(
                data: assignedPlayer,
                feedback: Material(
                  color: Colors.transparent,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: goldAccent,
                    child: Text(
                      assignedPlayer.number,
                      style: const TextStyle(
                        color: greenDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                child: playerWidget,
              ),
            );
          }

          return playerWidget;
        },
      ),
    );
  }
}
