// lib/widgets/cards/executed_disbursements_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';

class ExecutedDisbursementsCard extends StatelessWidget {
  const ExecutedDisbursementsCard({super.key});

  static const Color bordeauxRed = Color(0xFF6B1D2F);

  void _showExecutedDetails(BuildContext context) {
    final provider = context.read<AdminDashboardProvider>();
    final executedExpenses = provider.allExpenses
        .where((exp) => exp['status']?.toString().toLowerCase() == 'executed')
        .toList();

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
                    "Décaissements Exécutés",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: bordeauxRed,
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

              // Contenu détaillé des décaissements exécutés
              SizedBox(
                height: 220,
                child: executedExpenses.isEmpty
                    ? const Center(
                        child: Text(
                          "Aucun décaissement exécuté pour le moment",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        itemCount: executedExpenses.length,
                        itemBuilder: (context, index) {
                          final exp = executedExpenses[index];
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
                                backgroundColor: Color(0xFFFFEBEE),
                                radius: 14,
                                child: Icon(
                                  Icons.check_circle,
                                  color: bordeauxRed,
                                  size: 14,
                                ),
                              ),
                              title: Text(
                                exp['title'] ?? 'Décaissement',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                "${exp['description'] ?? 'Sans description'} • ${exp['date'] ?? exp['created_at'] ?? ''}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: Text(
                                "-${exp['amount'] ?? 0} F",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: bordeauxRed,
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

    final double rawTotal = provider.totalExecutedAmount;
    final int count = provider.executedCount;
    final bool isLoading =
        provider.isLoadingExecutedDisbursements || provider.isLoading;

    const bordeauxTheme = bordeauxRed;

    return InkWell(
      onTap: () => _showExecutedDetails(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bordeauxTheme.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: bordeauxTheme.withOpacity(0.2)),
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
                    color: bordeauxTheme.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: bordeauxTheme,
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
                          color: bordeauxTheme,
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
                      color: bordeauxTheme,
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Décaissements Exécutés",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: bordeauxTheme.withOpacity(0.8),
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
                      valueColor: AlwaysStoppedAnimation<Color>(bordeauxTheme),
                    ),
                  )
                else
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${rawTotal.toStringAsFixed(0)} FCFA",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: bordeauxTheme,
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
