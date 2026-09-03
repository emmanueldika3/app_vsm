import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/provider/announcement_provider.dart';
import 'announcement_card.dart';
import 'announcement_form_dialog.dart';

class AnnouncementsWidget extends StatelessWidget {
  const AnnouncementsWidget({super.key});

  // Couleurs Thème VSM
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color darkBg = Color(0xFF0A1E13);
  static const Color cardBg = Color(0xFF122E1F);

  void _openFormDialog(BuildContext context, {Announcement? announcement}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AnnouncementFormDialog(
        parentContext: context,
        announcement: announcement,
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isDeleting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: darkBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.redAccent, width: 0.8),
              ),
              title: const Text(
                'Supprimer le communiqué',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                'Voulez-vous vraiment supprimer ce communiqué ?',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setDialogState(() => isDeleting = true);
                          final provider = context.read<AnnouncementProvider>();
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(dialogContext);

                          try {
                            await provider.deleteAnnouncement(id);
                            navigator.pop();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Communiqué supprimé'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          } catch (e) {
                            setDialogState(() => isDeleting = false);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Erreur : $e'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                  child: isDeleting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Supprimer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnouncementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(color: goldAccent),
            ),
          );
        }

        final announcements = provider.announcements;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: goldAccent.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Entête avec bouton de création
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.campaign, color: goldAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Communiqués Officiels',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => _openFormDialog(context),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: greenPrimary,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: goldAccent, width: 0.8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: goldAccent, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Publier',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Liste
              if (announcements.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Aucun communiqué pour le moment',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: announcements.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: Colors.white10, height: 16),
                  itemBuilder: (context, index) {
                    final item = announcements[index];
                    return AnnouncementCard(
                      announcement: item,
                      onEdit: () =>
                          _openFormDialog(context, announcement: item),
                      onDelete: () => _confirmDelete(context, item.id),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
