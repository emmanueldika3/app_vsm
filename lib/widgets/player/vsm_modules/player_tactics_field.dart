import 'package:flutter/material.dart';
import 'package:vsm_app/models/prensentPlayers.dart';
import 'player_tactics_constants.dart';

class PlayerTacticsField {
  static List<Map<String, dynamic>> getPositionsForFormation(String formation) {
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
      case "4-5-1":
        return [
          {"pos": "GK", "top": 0.85, "left": 0.45},
          {"pos": "LB", "top": 0.65, "left": 0.12},
          {"pos": "CB1", "top": 0.68, "left": 0.35},
          {"pos": "CB2", "top": 0.68, "left": 0.58},
          {"pos": "RB", "top": 0.65, "left": 0.80},
          {"pos": "LM", "top": 0.42, "left": 0.15},
          {"pos": "LCM", "top": 0.45, "left": 0.32},
          {"pos": "CM", "top": 0.48, "left": 0.45},
          {"pos": "RCM", "top": 0.45, "left": 0.58},
          {"pos": "RM", "top": 0.42, "left": 0.75},
          {"pos": "ST", "top": 0.15, "left": 0.45},
        ];
      case "4-2-3-1":
        return [
          {"pos": "GK", "top": 0.85, "left": 0.45},
          {"pos": "LB", "top": 0.65, "left": 0.12},
          {"pos": "CB1", "top": 0.68, "left": 0.35},
          {"pos": "CB2", "top": 0.68, "left": 0.58},
          {"pos": "RB", "top": 0.65, "left": 0.80},
          {"pos": "CDM1", "top": 0.55, "left": 0.36},
          {"pos": "CDM2", "top": 0.55, "left": 0.57},
          {"pos": "LAM", "top": 0.32, "left": 0.20},
          {"pos": "CAM", "top": 0.30, "left": 0.45},
          {"pos": "RAM", "top": 0.32, "left": 0.70},
          {"pos": "ST", "top": 0.15, "left": 0.45},
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

  static Widget buildFieldWidget({
    required BuildContext context,
    required double fieldHeight,
    required String selectedFormation,
    required Map<String, PresentPlayer> assignedPlayers,
    required PresentPlayer? connectedPlayer,
    required Function(PresentPlayer, String) onPlayerTap,
  }) {
    final currentPositions = getPositionsForFormation(selectedFormation);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double fieldWidth = constraints.maxWidth;

        return Container(
          height: fieldHeight,
          width: fieldWidth,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                PlayerTacticsConstants.greenPrimary,
                PlayerTacticsConstants.greenDark,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: PlayerTacticsConstants.goldAccent,
              width: 2.5,
            ),
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
                      color: PlayerTacticsConstants.goldAccent.withOpacity(0.7),
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
                  color: PlayerTacticsConstants.goldAccent.withOpacity(0.4),
                ),
              ),
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: PlayerTacticsConstants.goldAccent.withOpacity(0.4),
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
                    color: PlayerTacticsConstants.goldAccent,
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
                      color: PlayerTacticsConstants.goldAccent.withOpacity(0.7),
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                ),
              ),
              for (var posData in currentPositions)
                _buildReadonlySlot(
                  context: context,
                  posKey: posData["pos"],
                  top: posData["top"] * fieldHeight,
                  left: posData["left"] * fieldWidth,
                  assignedPlayers: assignedPlayers,
                  connectedPlayer: connectedPlayer,
                  onPlayerTap: onPlayerTap,
                ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildReadonlySlot({
    required BuildContext context,
    required String posKey,
    required double top,
    required double left,
    required Map<String, PresentPlayer> assignedPlayers,
    required PresentPlayer? connectedPlayer,
    required Function(PresentPlayer, String) onPlayerTap,
  }) {
    final assignedPlayer = assignedPlayers[posKey];
    final bool isMe =
        connectedPlayer != null &&
        assignedPlayer != null &&
        connectedPlayer.id == assignedPlayer.id;

    return Positioned(
      top: top - 26,
      left: left - 28,
      child: GestureDetector(
        onTap: () {
          if (assignedPlayer != null) {
            onPlayerTap(assignedPlayer, posKey);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: assignedPlayer != null
                    ? PlayerTacticsConstants.bordeauxRed
                    : Colors.black26,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isMe
                      ? PlayerTacticsConstants.goldAccent
                      : Colors.white,
                  width: isMe ? 3.5 : 1.5,
                ),
                boxShadow: isMe
                    ? [
                        const BoxShadow(
                          color: PlayerTacticsConstants.goldAccent,
                          blurRadius: 10,
                          spreadRadius: 3,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  assignedPlayer != null ? assignedPlayer.number : posKey,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isMe
                    ? PlayerTacticsConstants.goldAccent
                    : Colors.black87,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                assignedPlayer != null
                    ? assignedPlayer.name.split(" ").last
                    : posKey,
                style: TextStyle(
                  color: isMe ? PlayerTacticsConstants.greenDark : Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
