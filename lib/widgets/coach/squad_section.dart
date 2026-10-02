import 'package:flutter/material.dart';
import 'package:vsm_app/models/squad_member.dart';
import 'package:vsm_app/widgets/coach/member_card.dart';

class SquadSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<SquadMember> members;
  final bool isUncertain;
  final Function(SquadMember member) onMemberTap;
  final Function(SquadMember member, String newStatus)? onStatusChanged;

  const SquadSection({
    Key? key,
    required this.title,
    required this.color,
    required this.members,
    this.isUncertain = false,
    required this.onMemberTap,
    this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête de section avec indicateur visuel coloré et compteur
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "$title (${members.length})",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Liste des membres ou message si vide
        members.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 8.0,
                ),
                child: Text(
                  isUncertain
                      ? "Aucun joueur incertain pour le moment."
                      : "Aucun joueur dans cette section.",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return MemberCard(
                    member: member,
                    isUncertain: isUncertain,
                    onTap: () => onMemberTap(member),
                    onStatusChanged: onStatusChanged != null
                        ? (newStatus) => onStatusChanged!(member, newStatus)
                        : null,
                  );
                },
              ),
      ],
    );
  }
}
