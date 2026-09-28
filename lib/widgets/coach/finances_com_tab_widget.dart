import 'package:flutter/material.dart';

class FinancesComTabWidget extends StatelessWidget {
  const FinancesComTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Suivi Cotisations & Communiqués",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.campaign, color: Color(0xFF1E5235)),
              title: const Text("Publier une note au groupe"),
              subtitle: const Text(
                "Envoyer une notification directe aux joueurs",
              ),
              trailing: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
