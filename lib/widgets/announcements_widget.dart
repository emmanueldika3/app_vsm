import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/announcement_provider.dart';
import '../models/announcement_model.dart';

class AnnouncementsWidget extends StatefulWidget {
  const AnnouncementsWidget({super.key});

  @override
  State<AnnouncementsWidget> createState() => _AnnouncementsWidgetState();
}

class _AnnouncementsWidgetState extends State<AnnouncementsWidget> {
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color bordeauxRed = Color(0xFF6B1D2F);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().fetchAnnouncements();
    });

    // Écoute du défilement pour la pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<AnnouncementProvider>().fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnouncementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.announcements.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: CircularProgressIndicator(color: greenPrimary),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec bouton Nouveau
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _showAnnouncementModal(context),
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text(
                  'Nouveau communiqué',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            if (provider.announcements.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                width: double.infinity,
                child: const Center(
                  child: Text(
                    'Aucun communiqué publié pour le moment.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    provider.announcements.length +
                    (provider.isFetchingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Loader en bas de liste lors du chargement de la page suivante
                  if (index == provider.announcements.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: CircularProgressIndicator(color: greenPrimary),
                      ),
                    );
                  }

                  final item = provider.announcements[index];
                  return _buildCard(context, item, provider);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    Announcement item,
    AnnouncementProvider provider,
  ) {
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (item.isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: bordeauxRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'URGENT',
                          style: TextStyle(
                            color: bordeauxRed,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: greenPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.category.toUpperCase(),
                        style: const TextStyle(
                          color: greenPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // Actions : Modifier & Supprimer
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Colors.blueGrey,
                      ),
                      onPressed: () =>
                          _showAnnouncementModal(context, existingItem: item),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.redAccent,
                      ),
                      onPressed: () async {
                        final confirm = await _showConfirmDelete(context);
                        if (confirm == true) {
                          await provider.deleteAnnouncement(item.id);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              item.content,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                if (item.targetAudience == 'board')
                  const Text(
                    '🔒 Bureau uniquement',
                    style: TextStyle(
                      fontSize: 11,
                      color: bordeauxRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Modal unique servant à la Création ET à la Modification
  void _showAnnouncementModal(
    BuildContext context, {
    Announcement? existingItem,
  }) {
    final isEditing = existingItem != null;
    final titleController = TextEditingController(
      text: isEditing ? existingItem.title : '',
    );
    final contentController = TextEditingController(
      text: isEditing ? existingItem.content : '',
    );
    String category = isEditing ? existingItem.category : 'general';
    String targetAudience = isEditing ? existingItem.targetAudience : 'all';
    bool isUrgent = isEditing ? existingItem.isUrgent : false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEditing
                          ? 'Modifier le communiqué'
                          : 'Créer un communiqué',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: greenPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Titre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: contentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Contenu',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Catégorie'),
                      items: const [
                        DropdownMenuItem(
                          value: 'general',
                          child: Text('Général'),
                        ),
                        DropdownMenuItem(
                          value: 'training',
                          child: Text('Entraînement'),
                        ),
                        DropdownMenuItem(value: 'match', child: Text('Match')),
                        DropdownMenuItem(
                          value: 'meeting',
                          child: Text('Réunion'),
                        ),
                      ],
                      onChanged: (val) => setModalState(() => category = val!),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: targetAudience,
                      decoration: const InputDecoration(
                        labelText: 'Audience cible',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('Tout le monde'),
                        ),
                        DropdownMenuItem(
                          value: 'board',
                          child: Text('Membres du bureau'),
                        ),
                      ],
                      onChanged: (val) =>
                          setModalState(() => targetAudience = val!),
                    ),
                    SwitchListTile(
                      title: const Text('Urgent'),
                      activeColor: bordeauxRed,
                      value: isUrgent,
                      onChanged: (val) => setModalState(() => isUrgent = val),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenPrimary,
                        minimumSize: const Size.fromHeight(45),
                      ),
                      onPressed: () async {
                        if (titleController.text.isNotEmpty &&
                            contentController.text.isNotEmpty) {
                          final provider = context.read<AnnouncementProvider>();
                          bool success;

                          if (isEditing) {
                            success = await provider.updateAnnouncement(
                              id: existingItem.id,
                              title: titleController.text,
                              content: contentController.text,
                              category: category,
                              targetAudience: targetAudience,
                              isUrgent: isUrgent,
                            );
                          } else {
                            success = await provider.addAnnouncement(
                              title: titleController.text,
                              content: contentController.text,
                              category: category,
                              targetAudience: targetAudience,
                              isUrgent: isUrgent,
                            );
                          }

                          if (mounted && success) {
                            Navigator.pop(ctx);
                          }
                        }
                      },
                      child: Text(
                        isEditing ? 'Mettre à jour' : 'Publier',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool?> _showConfirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Suppression'),
        content: const Text('Voulez-vous supprimer ce communiqué ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: bordeauxRed),
            ),
          ),
        ],
      ),
    );
  }
}
