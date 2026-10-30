import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsm_app/models/squad_member.dart';

class MemberCard extends StatelessWidget {
  final SquadMember member;
  final int eventId;
  final bool isUncertain;
  final VoidCallback onTap;
  final VoidCallback? onPresenceUpdated;
  final bool isCoach; // 1. Ajout de la variable pour le rôle

  const MemberCard({
    Key? key,
    required this.member,
    required this.eventId,
    this.isUncertain = false,
    required this.onTap,
    this.onPresenceUpdated,
    required this.isCoach, // 2. Rendu obligatoire dans le constructeur
  }) : super(key: key);

  /// Méthode d'appel de l'API Laravel pour modifier le statut du joueur par le coach
  Future<void> _updateCoachPresence(
    BuildContext context,
    String newStatus,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      // Remplace par ton URL de base API ou utilise ta variable globale
      const String baseUrl = 'http://127.0.0.1:8000/api';
      final url = Uri.parse('$baseUrl/events/$eventId/presences/${member.id}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': newStatus, // 'present' ou 'absent'
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Statut de ${member.name} mis à jour : $newStatus'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Notifier le composant parent pour recharger l'événement et le banc de touche
        if (onPresenceUpdated != null) {
          onPresenceUpdated!();
        }
      } else {
        throw Exception(
          'Échec de la mise à jour (code ${response.statusCode})',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color greenPrimary = Color(0xFF1E5235);
    const Color bordeauxRed = Color(0xFF6B1D2F);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Numéro du maillot / avatar du joueur
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: greenPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  member.number,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: greenPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Informations du membre (Nom, Poste, Stats)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${member.position} • Présences : ${member.presentCount}/${member.totalEvents}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // 3. Condition d'affichage : Si c'est un COACH ET que le membre est incertain -> Afficher les boutons de validation
              if (isCoach && isUncertain) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bouton Valider Présent
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      icon: const Icon(Icons.check_circle, color: greenPrimary),
                      tooltip: "Marquer présent",
                      onPressed: () => _updateCoachPresence(context, "present"),
                    ),
                    // Bouton Valider Absent
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      icon: const Icon(Icons.cancel, color: bordeauxRed),
                      tooltip: "Marquer absent",
                      onPressed: () => _updateCoachPresence(context, "absent"),
                    ),
                  ],
                ),
              ] else ...[
                // Pour le joueur (ou si ce n'est pas incertain), simple flèche informative
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
