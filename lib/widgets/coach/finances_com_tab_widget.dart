import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/widgets/cash_balance_card.dart';
import 'package:vsm_app/widgets/collected_contributions_card.dart';
import 'package:vsm_app/widgets/executed_disbursements_card.dart';
import 'package:vsm_app/widgets/coach/member_financial_summary_card.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';
import 'package:vsm_app/provider/auth_provider.dart';

class FinancesComTabWidget extends StatefulWidget {
  const FinancesComTabWidget({super.key});

  @override
  State<FinancesComTabWidget> createState() => _FinancesComTabWidgetState();
}

class _FinancesComTabWidgetState extends State<FinancesComTabWidget> {
  @override
  void initState() {
    super.initState();
    // Exécution après le premier rendu pour charger les données de la base
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// Charge ou rafraîchit les données financières avec le token Sanctum
  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final dashboardProvider = context.read<AdminDashboardProvider>();

    final token = authProvider.token;
    if (token != null && token.isNotEmpty) {
      await dashboardProvider.fetchDashboardData(token);
    }
  }

  static const Color greenPrimary = Color(0xFF1E5235);

  @override
  Widget build(BuildContext context) {
    // On récupère l'AuthProvider pour extraire le token
    final authProvider = context.watch<AuthProvider>();
    final token = authProvider.token ?? '';

    return Consumer<AdminDashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return RefreshIndicator(
          onRefresh: _loadData,
          color: greenPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Suivi Financier",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: greenPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Carrousel horizontal des cartes financières dynamiques
                SizedBox(
                  height: 125,
                  child: dashboardProvider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: greenPrimary),
                        )
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: const [
                            SizedBox(width: 160, child: CashBalanceCard()),
                            SizedBox(width: 12),
                            SizedBox(
                              width: 160,
                              child: CollectedContributionsCard(),
                            ),
                            SizedBox(width: 12),
                            SizedBox(
                              width: 160,
                              child: ExecutedDisbursementsCard(),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      color: greenPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Détails & Opérations",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: greenPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Intégration sans userId (récupération automatique via le token)
                MemberFinancialSummaryCard(token: token),

                // Affichage conditionnel en cas d'erreur de chargement
                if (dashboardProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        dashboardProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
