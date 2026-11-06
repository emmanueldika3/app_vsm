import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';

class ExpensesMonthCard extends StatelessWidget {
  final VoidCallback? onTap;

  const ExpensesMonthCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final double totalMonth = provider.monthExpensesTotal;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 18,
                    color: Color(0xFF6B1D2F),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Dépenses du mois",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "$totalMonth FCFA",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B1D2F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
