import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';

class ExpensesTodayCard extends StatelessWidget {
  const ExpensesTodayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final double totalToday = provider.todayExpensesTotal;

    return Card(
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
                Icon(Icons.today, size: 18, color: Color(0xFF6B1D2F)),
                SizedBox(width: 8),
                Text(
                  "Dépenses du jour",
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
              "$totalToday FCFA",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B1D2F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
