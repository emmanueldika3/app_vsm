// lib/widgets/players_list_widget.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlayersListWidget extends StatelessWidget {
  final String apiUrl;

  const PlayersListWidget({Key? key, required this.apiUrl}) : super(key: key);

  Future<List<dynamic>> fetchAvailablePlayers() async {
    final response = await http.get(Uri.parse('$apiUrl/api/players/available'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Échec du chargement des joueurs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchAvailablePlayers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucun joueur disponible trouvé.'));
        }

        final players = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green[800],
                  child: Text(
                    player['name'] != null && player['name'].isNotEmpty
                        ? player['name'][0].toUpperCase()
                        : 'J',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(player['name'] ?? 'Nom inconnu'),
                subtitle: Text(
                  'Poste: ${player['position'] ?? 'Non spécifié'}',
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    player['status'] ?? 'Disponible',
                    style: TextStyle(color: Colors.green[900], fontSize: 12),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
