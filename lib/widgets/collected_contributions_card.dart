// lib/widgets/cards/collected_contributions_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';

class CollectedContributionsCard extends StatelessWidget {
  const CollectedContributionsCard({super.key});

  void _showContributionsDetails(BuildContext context) {
    final provider = context.read<AdminDashboardProvider>();

    // Récupération de la liste des contributions depuis le provider ou une source associée
    // (Adapte cette liste selon les données disponibles dans ton provider, par exemple provider.allContributions si elle existe)
    final List<dynamic> collectedList =
        []; // Remplacer par provider.collectedContributionsList si disponible, ou filtrer depuis le dashboard

    const Color greenPrimary = Color(0xFF1E5235);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 25,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // En-tête avec titre et bouton de fermeture (x)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  const Text(
                    "Détails des Cotisations Perçues",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: greenPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),

              // Contenu détaillé sous forme de liste unifiée
              SizedBox(
                height: 220,
                child: collectedList.isEmpty
                    ? const Center(
                        child: Text(
                          "Aucune contribution détaillée pour le moment",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        itemCount: collectedList.length,
                        itemBuilder: (context, index) {
                          final item = collectedList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: ListTile(
                              dense: true,
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFE8F5E9),
                                radius: 14,
                                child: Icon(
                                  Icons.savings,
                                  color: greenPrimary,
                                  size: 14,
                                ),
                              ),
                              title: Text(
                                item['title'] ?? 'Cotisation membre',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                "${item['description'] ?? 'Paiement validé'} • ${item['date'] ?? item['created_at'] ?? ''}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: Text(
                                "+${item['amount'] ?? 0} F",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: greenPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final model = provider.collectedContributions;
    final isLoading = provider.isLoadingCollectedContributions;

    final rawTotal = model?.totalCollected ?? 0.0;
    final currency = model?.currency ?? 'FCFA';
    final count = model?.contributionsCount ?? 0;

    const greenTheme = Color(0xFF2E7D32);

    return InkWell(
      onTap: () => _showContributionsDetails(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: greenTheme.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: greenTheme.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: greenTheme.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.savings_outlined,
                    color: greenTheme,
                    size: 16,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (count > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: greenTheme,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "$count",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: greenTheme,
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cotisations Perçues",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: greenTheme.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                if (isLoading)
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(greenTheme),
                    ),
                  )
                else
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${rawTotal.toStringAsFixed(0)} $currency",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: greenTheme,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
