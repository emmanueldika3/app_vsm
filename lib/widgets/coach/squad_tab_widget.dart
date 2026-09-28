import 'package:flutter/material.dart';

class SquadTabWidget extends StatelessWidget {
  const SquadTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          "Gestion de l'Effectif",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF1E5235),
              child: Text("7", style: TextStyle(color: Colors.white)),
            ),
            title: const Text("Emmanuel Dika"),
            subtitle: const Text("Ailier Droit (RW) • Présent"),
            trailing: Chip(
              label: const Text(
                "Convoqué",
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
              backgroundColor: Colors.green[700],
            ),
          ),
        ),
      ],
    );
  }
}
