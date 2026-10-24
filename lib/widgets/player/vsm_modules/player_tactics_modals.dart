import 'package:flutter/material.dart';
import 'package:vsm_app/models/prensentPlayers.dart';
import 'package:vsm_app/models/event_model.dart';
import 'player_tactics_constants.dart';
import 'player_tactics_field.dart';

class PlayerTacticsModals {
  static void showFullScreenTacticalModal({
    required BuildContext context,
    required EventModel event,
    required String selectedFormation,
    required Map<String, PresentPlayer> assignedPlayers,
    required PresentPlayer? connectedPlayer,
    required String statusText,
    required Function(PresentPlayer, String) onPlayerTap,
  }) {
    // Utilisation directe du statusText calculé par le parent avec un fallback propre
    String computedStatusText = statusText.isNotEmpty
        ? statusText
        : "Non identifié";

    // Détermination visuelle (couleur/icône) selon que le texte indique un titulaire ou non
    bool isCurrentlyStarter = computedStatusText.toLowerCase().contains(
      "titulaire",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.94,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dispositif & Consignes (Plein Écran)",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: PlayerTacticsConstants.greenDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  PlayerTacticsField.buildFieldWidget(
                    context: context,
                    fieldHeight: 380.0,
                    selectedFormation: selectedFormation,
                    assignedPlayers: assignedPlayers,
                    connectedPlayer: connectedPlayer,
                    onPlayerTap: onPlayerTap,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrentlyStarter
                          ? PlayerTacticsConstants.goldAccent.withOpacity(0.15)
                          : Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCurrentlyStarter
                            ? PlayerTacticsConstants.goldAccent
                            : Colors.orange,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isCurrentlyStarter
                              ? Icons.star
                              : Icons.person_outline,
                          color: isCurrentlyStarter
                              ? PlayerTacticsConstants.greenPrimary
                              : Colors.orange[800],
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Statut : $computedStatusText",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isCurrentlyStarter
                                  ? PlayerTacticsConstants.greenDark
                                  : Colors.orange[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Consignes Tactiques",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: PlayerTacticsConstants.greenPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "• Consignes collectives : Bloc équipe compact, coulissage synchrone du côté du ballon et transition offensive rapide.\n\n• Consignes individuelles : Maintenez une concentration maximale sur votre zone d'intervention et appliquez les consignes du staff pour l'événement.",
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showTacticalDetailsModal({
    required BuildContext context,
    required PresentPlayer player,
    required String positionName,
    required String selectedFormation,
    required EventModel event,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.70,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: PlayerTacticsConstants.greenPrimary,
                  child: Text(
                    player.number,
                    style: const TextStyle(
                      color: PlayerTacticsConstants.goldAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: PlayerTacticsConstants.greenDark,
                        ),
                      ),
                      Text(
                        "Poste : $positionName ($selectedFormation)",
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    "Consignes Collectives",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: PlayerTacticsConstants.greenPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "• Bloc équipe compact, coulissage synchrone du côté du ballon.\n• Transition offensive rapide dès la récupération.",
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Consignes Individuelles & Poste",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: PlayerTacticsConstants.bordeauxRed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF0F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "• Assurer la couverture rigoureuse et le premier pressing dans votre zone.\n• Discipline tactique pour l'événement : ${event.title}.",
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
