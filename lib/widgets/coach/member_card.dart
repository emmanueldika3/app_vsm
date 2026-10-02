import 'package:flutter/material.dart';
import 'package:vsm_app/models/squad_member.dart';

class MemberCard extends StatelessWidget {
  final SquadMember member;
  final bool isUncertain;
  final VoidCallback onTap;
  final Function(String newStatus)? onStatusChanged;

  const MemberCard({
    Key? key,
    required this.member,
    this.isUncertain = false,
    required this.onTap,
    this.onStatusChanged,
  }) : super(key: key);

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
              // Numéro du maillot ou avatar
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

              // Informations du joueur (Nom, Poste, Stats)
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

              // Si le joueur est incertain, on affiche les boutons de validation pour le coach
              if (isUncertain && onStatusChanged != null) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bouton Valider Présent
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      icon: const Icon(Icons.check_circle, color: greenPrimary),
                      tooltip: "Marquer présent",
                      onPressed: () => onStatusChanged!("present"),
                    ),
                    // Bouton Valider Absent
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      icon: const Icon(Icons.cancel, color: bordeauxRed),
                      tooltip: "Marquer absent",
                      onPressed: () => onStatusChanged!("absent"),
                    ),
                  ],
                ),
              ] else ...[
                // Simple flèche ou indicateur visuel au bout si ce n'est pas incertain
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
