import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';

class ActiveMembersListWidget extends StatelessWidget {
  final String token;

  const ActiveMembersListWidget({Key? key, required this.token})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminDashboardProvider>(context);
    final members = provider.activeMembers;

    if (provider.isLoadingActiveMembers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (members.isEmpty) {
      return const Center(child: Text("Aucun membre trouvé."));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index] as Map<String, dynamic>;
        final String name = member['name'] ?? 'Nom inconnu';
        final String email = member['email'] ?? '';
        final String role = member['role'] ?? 'player';
        final String status = member['status'] ?? 'active';

        // Un membre est suspendu soit par son statut 'suspended', soit par inactive/is_active = 0
        final bool isSuspended =
            status == 'suspended' ||
            member['is_active'] == 0 ||
            member['is_active'] == false;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: isSuspended ? Colors.grey.shade100 : Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSuspended ? Colors.grey.shade400 : Colors.blue,
              child: Text(
                name.trim().isNotEmpty
                    ? name
                          .trim()
                          .split(RegExp(r'\s+'))
                          .take(2)
                          .map((e) => e[0].toUpperCase())
                          .join(' ')
                    : 'U',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSuspended ? Colors.grey.shade700 : Colors.black,
                decoration: isSuspended ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: TextStyle(
                    color: isSuspended ? Colors.grey.shade600 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),

                // --- AFFICHAGE CONDITIONNEL : Rôle OU Mentions Suspendu ---
                if (isSuspended)
                  const Chip(
                    label: Text(
                      'Suspendu',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.red,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )
                else
                  Chip(
                    label: Text(
                      _getRoleLabel(role),
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                    backgroundColor: _getRoleColor(role),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'role') {
                  _showChangeRoleModal(context, token, member);
                } else if (value == 'status') {
                  _confirmToggleStatus(context, token, member, isSuspended);
                }
              },
              itemBuilder: (context) => [
                // Modifier le rôle n'est accessible que si le membre est actif
                if (!isSuspended)
                  const PopupMenuItem(
                    value: 'role',
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings, color: Colors.blue),
                        SizedBox(width: 8),
                        Text("Modifier le rôle"),
                      ],
                    ),
                  ),

                // --- BOUTON DYNAMIQUE : "Activer" SI suspendu, SINON "Suspendre" ---
                PopupMenuItem(
                  value: 'status',
                  child: Row(
                    children: [
                      Icon(
                        isSuspended ? Icons.check_circle_outline : Icons.block,
                        color: isSuspended ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isSuspended ? "Activer" : "Suspendre",
                        style: TextStyle(
                          color: isSuspended ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'president':
        return 'Président';
      case 'admin':
        return 'Administrateur';
      case 'treasurer':
        return 'Trésorier';
      case 'coach':
        return 'Coach';
      default:
        return 'Joueur';
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'president':
        return Colors.purple;
      case 'admin':
        return Colors.indigo;
      case 'treasurer':
        return Colors.amber.shade800;
      case 'coach':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
  }

  void _showChangeRoleModal(
    BuildContext context,
    String token,
    Map<String, dynamic> member,
  ) {
    String selectedRole = member['role'] ?? 'player';

    final Map<String, String> rolesMap = {
      'president': 'Président',
      'admin': 'Administrateur',
      'treasurer': 'Trésorier',
      'coach': 'Coach',
      'player': 'Joueur',
    };

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Changer le rôle de ${member['name']}"),
              content: DropdownButtonFormField<String>(
                value: selectedRole,
                items: rolesMap.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => selectedRole = val);
                },
                decoration: const InputDecoration(
                  labelText: "Nouveau rôle",
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final provider = Provider.of<AdminDashboardProvider>(
                      context,
                      listen: false,
                    );

                    final success = await provider.updateMemberRole(
                      token: token,
                      userId: member['id'],
                      newRole: selectedRole,
                    );

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? "Rôle mis à jour avec succès !"
                                : "Échec de la modification du rôle.",
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text("Enregistrer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmToggleStatus(
    BuildContext context,
    String token,
    Map<String, dynamic> member,
    bool isCurrentlySuspended,
  ) {
    final String actionText = isCurrentlySuspended ? "activer" : "suspendre";

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            "${isCurrentlySuspended ? 'Activation' : 'Suspension'} du compte",
          ),
          content: Text(
            "Voulez-vous vraiment $actionText le compte de ${member['name']} ?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentlySuspended
                    ? Colors.green
                    : Colors.red,
              ),
              onPressed: () async {
                final provider = Provider.of<AdminDashboardProvider>(
                  context,
                  listen: false,
                );

                // Si actuellement suspendu, alors on lance l'activation (activate: true)
                final success = await provider.toggleMemberStatus(
                  token: token,
                  userId: member['id'],
                  activate: isCurrentlySuspended,
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);

                  // Mise à jour immédiate du statut dans l'objet local du provider pour forcer le redessin de l'item
                  if (success) {
                    member['status'] = isCurrentlySuspended
                        ? 'active'
                        : 'suspended';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? "Le compte a été ${isCurrentlySuspended ? 'activé' : 'suspendu'} avec succès !"
                            : "Échec du changement de statut.",
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                isCurrentlySuspended ? "Activer" : "Suspendre",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
