import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/provider/announcement_provider.dart';
import 'announcements_widget.dart';

class AnnouncementFormDialog extends StatefulWidget {
  final BuildContext parentContext;
  final Announcement? announcement;

  const AnnouncementFormDialog({
    super.key,
    required this.parentContext,
    this.announcement,
  });

  @override
  State<AnnouncementFormDialog> createState() => _AnnouncementFormDialogState();
}

class _AnnouncementFormDialogState extends State<AnnouncementFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late bool _isUrgent;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.announcement?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.announcement?.content ?? '',
    );
    _isUrgent = widget.announcement?.isUrgent ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) return;

    setState(() => _isSubmitting = true);

    final provider = widget.parentContext.read<AnnouncementProvider>();
    final messenger = ScaffoldMessenger.of(widget.parentContext);
    final navigator = Navigator.of(context);
    final isEditing = widget.announcement != null;

    try {
      if (isEditing) {
        await provider.updateAnnouncement(
          id: widget.announcement!.id,
          title: title,
          content: content,
          isUrgent: _isUrgent,
        );
      } else {
        await provider.addAnnouncement(
          title: title,
          content: content,
          isUrgent: _isUrgent,
        );
      }

      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Communiqué mis à jour !'
                : 'Communiqué publié avec succès !',
          ),
          backgroundColor: AnnouncementsWidget.greenPrimary,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.announcement != null;

    return AlertDialog(
      backgroundColor: AnnouncementsWidget.darkBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AnnouncementsWidget.goldAccent,
          width: 0.8,
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AnnouncementsWidget.greenPrimary,
              shape: BoxShape.circle,
              border: Border.all(
                color: AnnouncementsWidget.goldAccent,
                width: 0.8,
              ),
            ),
            child: Icon(
              isEditing ? Icons.edit : Icons.campaign,
              color: AnnouncementsWidget.goldAccent,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            isEditing ? 'Modifier Communiqué' : 'Nouveau Communiqué',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              enabled: !_isSubmitting,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Titre du communiqué',
                labelStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: AnnouncementsWidget.goldAccent,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.black26,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              enabled: !_isSubmitting,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Contenu du communiqué...',
                labelStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white24),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: AnnouncementsWidget.goldAccent,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.black26,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text(
                'Marquer comme URGENT',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              value: _isUrgent,
              activeColor: Colors.redAccent,
              dense: true,
              contentPadding: EdgeInsets.zero,
              onChanged: _isSubmitting
                  ? null
                  : (bool val) => setState(() => _isUrgent = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AnnouncementsWidget.goldAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : Text(
                  isEditing ? 'Enregistrer' : 'Publier',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
