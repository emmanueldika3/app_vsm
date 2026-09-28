import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/admin_dashboard_provider.dart';

class OrdonnancementCenterWidget extends StatefulWidget {
  final String userToken;

  const OrdonnancementCenterWidget({super.key, required this.userToken});

  @override
  State<OrdonnancementCenterWidget> createState() =>
      _OrdonnancementCenterWidgetState();
}

class _OrdonnancementCenterWidgetState
    extends State<OrdonnancementCenterWidget> {
  static const Color greenPrimary = Color(0xFF1E5235);
  final TextEditingController _rejectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().fetchPendingDisbursements(
        widget.userToken,
      );
    });
  }

  @override
  void dispose() {
    _rejectionController.dispose();
    super.dispose();
  }

  void _showRejectionDialog(BuildContext context, dynamic expense) {
    _rejectionController.clear();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Rejeter la demande #${expense['id']}'),
          content: TextField(
            controller: _rejectionController,
            decoration: const InputDecoration(
              labelText: 'Motif du rejet',
              hintText: 'Ex: Budget insuffisant, justificatif manquant...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final reason = _rejectionController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez saisir un motif de rejet.'),
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                await _processExpense(
                  expense['id'],
                  'rejected',
                  reason: reason,
                );
              },
              child: const Text(
                'Confirmer le rejet',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processExpense(int id, String status, {String? reason}) async {
    final provider = context.read<AdminDashboardProvider>();

    final success = await provider.ordonnerDecaissement(
      token: widget.userToken,
      expenseId: id,
      status: status,
      rejectionReason: reason,
    );

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved'
                ? 'Demande approuvée avec succès.'
                : 'Demande rejetée.',
          ),
          backgroundColor: status == 'approved' ? Colors.green : Colors.orange,
        ),
      );

      provider.fetchPendingDisbursements(widget.userToken);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Une erreur est survenue.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardProvider>(
      builder: (context, provider, child) {
        final pendingList = provider.pendingDisbursementsList;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- EN-TÊTE ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Demandes en attente de validation",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: greenPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (!provider.isLoadingPending && pendingList.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${pendingList.length}',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // --- CONTENU PRINCIPAL ---
            if (provider.isLoadingPending)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: CircularProgressIndicator(color: greenPrimary),
                ),
              )
            else if (pendingList.isEmpty)
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      'Aucune demande en attente pour le moment.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  final int crossAxisCount = width > 900
                      ? 3
                      : (width > 600 ? 2 : 1);

                  if (crossAxisCount == 1) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pendingList.length,
                      itemBuilder: (context, index) {
                        return _buildVerticalCard(pendingList[index]);
                      },
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pendingList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio:
                          1.1, // Aspect ratio adapté pour une disposition verticale (3 niveaux)
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      return _buildVerticalCard(pendingList[index]);
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }

  /// Carte organisée en 1 colonne de 3 lignes : Icône -> Texte -> Boutons
  Widget _buildVerticalCard(dynamic item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- LIGNE 1 : Icône en haut ---
            const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.orangeAccent,
              child: Icon(Icons.pending_actions, color: Colors.white, size: 24),
            ),

            const SizedBox(height: 8),

            // --- LIGNE 2 : Bloc de Texte au milieu ---
            Column(
              children: [
                Text(
                  item['motif'] ??
                      item['description'] ??
                      'Décaissement sans motif',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Demandé par: ${item['user']?['name'] ?? 'Inconnu'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Montant: ${item['amount']} FCFA',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // --- LIGNE 3 : Icônes / Boutons d'action en bas ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  ),
                  tooltip: 'Approuver',
                  onPressed: () => _processExpense(item['id'], 'approved'),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red, size: 32),
                  tooltip: 'Rejeter',
                  onPressed: () => _showRejectionDialog(context, item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
