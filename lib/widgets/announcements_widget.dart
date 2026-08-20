// lib/widgets/announcements_widget.dart
import 'package:flutter/material.dart';

class AnnouncementsWidget extends StatelessWidget {
  final List<Map<String, String>> announcements;

  const AnnouncementsWidget({Key? key, required this.announcements})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (announcements.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Aucun communiqué officiel pour le moment.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Communiqués de la Direction',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final item = announcements[index];
            return Card(
              color: Colors.amber[50],
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.campaign, color: Colors.amber),
                title: Text(
                  item['title'] ?? 'Communiqué',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(item['content'] ?? ''),
                trailing: Text(
                  item['date'] ?? '',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
