import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/widgets/cash_balance_card.dart';
import 'package:vsm_app/widgets/collected_contributions_card.dart';
import 'package:vsm_app/widgets/executed_disbursements_card.dart';
import 'package:vsm_app/widgets/pending_disbursements_card.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';
import 'package:vsm_app/provider/auth_provider.dart';

class FinancialTabWidget extends StatefulWidget {
  const FinancialTabWidget({super.key});

  @override
  State<FinancialTabWidget> createState() => _FinancialTabWidgetState();
}

class _FinancialTabWidgetState extends State<FinancialTabWidget> {
  static const Color greenPrimary = Color(0xFF1E5235);

  @override
  void initState() {
    super.initState();
    // Exécution après le premier rendu du layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// Charge ou rafraîchit les données financières avec le token Sanctum
  Future<void> _loadData() async {
    final token = context.read<AuthProvider>().token;
    if (token != null && token.isNotEmpty) {
      await context.read<AdminDashboardProvider>().fetchDashboardData(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: greenPrimary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre d'Aperçu Général
            const Text(
              "Aperçu Général",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: greenPrimary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),

            // Carrousel horizontal des cartes financières
            SizedBox(
              height: 125,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: const [
                  SizedBox(width: 160, child: CashBalanceCard()),
                  SizedBox(width: 12),
                  SizedBox(width: 160, child: CollectedContributionsCard()),
                  SizedBox(width: 12),
                  SizedBox(width: 160, child: ExecutedDisbursementsCard()),
                  SizedBox(width: 12),
                  SizedBox(width: 160, child: PendingDisbursementsCard()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
