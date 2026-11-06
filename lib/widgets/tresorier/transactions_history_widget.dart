import 'package:flutter/material.dart';

class TransactionsHistoryWidget extends StatelessWidget {
  final List<dynamic> transactionsList;
  final Function(Map<String, dynamic>)? onEdit;
  final Function(int)? onDelete;
  final Function(Map<String, dynamic>)?
  onTap; // Ajout du callback pour les détails

  const TransactionsHistoryWidget({
    super.key,
    required this.transactionsList,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (transactionsList.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text(
            "Aucune transaction enregistrée.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final tx = transactionsList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            // Permet de cliquer sur toute la ligne pour afficher les détails
            onTap: onTap != null ? () => onTap!(tx) : null,
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1E5235).withOpacity(0.1),
              child: const Icon(Icons.arrow_downward, color: Color(0xFF1E5235)),
            ),
            title: Text(
              tx['memberName'] ?? 'Membre VSM',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Type: ${tx['type']} • Date: ${tx['date']}",
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${tx['amount']} XAF",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E5235),
                  ),
                ),
                // Bouton Modifier
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                    onPressed: () => onEdit!(tx),
                  ),
                // Bouton Supprimer
                if (onDelete != null && tx['id'] != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      size: 18,
                      color: Color(0xFF6B1D2F),
                    ),
                    onPressed: () => onDelete!(tx['id']),
                  ),
              ],
            ),
          ),
        );
      }, childCount: transactionsList.length),
    );
  }
}
