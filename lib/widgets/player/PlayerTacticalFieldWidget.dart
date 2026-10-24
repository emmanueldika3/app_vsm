import 'package:flutter/material.dart';
import 'package:vsm_app/models/prensentPlayers.dart';
import 'package:vsm_app/models/event_model.dart';
import 'vsm_modules/player_tactics_constants.dart';
import 'vsm_modules/player_tactics_field.dart';
import 'vsm_modules/player_tactics_modals.dart';

class PlayerTacticsTabWidget extends StatelessWidget {
  final EventModel event;
  final String selectedFormation;
  final Map<String, PresentPlayer> assignedPlayers;
  final List<PresentPlayer> substitutePlayers;
  final PresentPlayer? connectedPlayer;
  final String apiStatusText;

  const PlayerTacticsTabWidget({
    Key? key,
    required this.event,
    required this.selectedFormation,
    required this.assignedPlayers,
    required this.substitutePlayers,
    this.connectedPlayer,
    this.apiStatusText = "Non identifié",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Utilisation prioritaire du statut renvoyé par l'API backend
    final String statusText =
        (apiStatusText.isNotEmpty && apiStatusText != "Non identifié")
        ? apiStatusText
        : _getPlayerStatusText();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- 1. CARTE DE STATUT DU JOUEUR CONNECTÉ ---
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: PlayerTacticsConstants.goldAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: PlayerTacticsConstants.goldAccent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.person_pin_circle,
                color: PlayerTacticsConstants.goldAccent,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      connectedPlayer != null
                          ? "Statut : ${connectedPlayer!.name}"
                          : "Statut du joueur",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: PlayerTacticsConstants.greenPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: PlayerTacticsConstants.greenDark,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.fullscreen,
                  color: PlayerTacticsConstants.greenPrimary,
                  size: 28,
                ),
                tooltip: "Affichage plein écran",
                onPressed: () =>
                    PlayerTacticsModals.showFullScreenTacticalModal(
                      context: context,
                      event: event,
                      selectedFormation: selectedFormation,
                      assignedPlayers: assignedPlayers,
                      connectedPlayer: connectedPlayer,
                      statusText: statusText,
                      onPlayerTap: (player, pos) =>
                          PlayerTacticsModals.showTacticalDetailsModal(
                            context: context,
                            player: player,
                            positionName: pos,
                            selectedFormation: selectedFormation,
                            event: event,
                          ),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // --- 2. LE TERRAIN TACTIQUE (11 PROBABLE) ---
        const Text(
          "11 Type & Composition",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: PlayerTacticsConstants.greenDark,
          ),
        ),
        const SizedBox(height: 8),
        PlayerTacticsField.buildFieldWidget(
          context: context,
          fieldHeight: 460.0,
          selectedFormation: selectedFormation,
          assignedPlayers: assignedPlayers,
          connectedPlayer: connectedPlayer,
          onPlayerTap: (player, pos) =>
              PlayerTacticsModals.showTacticalDetailsModal(
                context: context,
                player: player,
                positionName: pos,
                selectedFormation: selectedFormation,
                event: event,
              ),
        ),
        const SizedBox(height: 20),

        // --- 3. LE BANC DE TOUCHE ---
        const Text(
          "Remplaçants & Convoqués sur le banc",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: PlayerTacticsConstants.greenDark,
          ),
        ),
        const SizedBox(height: 8),
        substitutePlayers.isNotEmpty
            ? SizedBox(
                height: 65,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: substitutePlayers.length,
                  itemBuilder: (context, index) {
                    final player = substitutePlayers[index];
                    final bool isMe =
                        connectedPlayer != null &&
                        connectedPlayer!.id.toString() == player.id.toString();

                    return GestureDetector(
                      onTap: () => PlayerTacticsModals.showTacticalDetailsModal(
                        context: context,
                        player: player,
                        positionName: "Banc de touche",
                        selectedFormation: selectedFormation,
                        event: event,
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? PlayerTacticsConstants.goldAccent.withOpacity(
                                  0.2,
                                )
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isMe
                                ? PlayerTacticsConstants.goldAccent
                                : Colors.grey.shade300,
                            width: isMe ? 2.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  PlayerTacticsConstants.bordeauxRed,
                              child: Text(
                                player.number,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              player.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isMe
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: PlayerTacticsConstants.greenDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            : Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Aucun remplaçant enregistré pour le moment.",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
      ],
    );
  }

  String _getPlayerStatusText() {
    if (connectedPlayer == null) return "Non identifié";

    String currentIdStr = connectedPlayer!.id.toString();

    // 1. Vérifier s'il est dans le 11 de départ
    for (var entry in assignedPlayers.entries) {
      if (entry.value.id.toString() == currentIdStr) {
        return "Titulaire (${entry.key}) - Schéma $selectedFormation";
      }
    }

    // 2. Vérifier s'il est sur le banc des remplaçants
    for (var sub in substitutePlayers) {
      if (sub.id.toString() == currentIdStr) {
        return "Sur le banc des remplaçants";
      }
    }

    return "Présent (Non positionné dans le 11 initial)";
  }
}
