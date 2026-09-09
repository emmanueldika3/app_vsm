import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';

class CollectedContributionsCard extends StatelessWidget {
  final VoidCallback? onTap;

  const CollectedContributionsCard({super.key, this.onTap});

  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color goldAccent = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    // Écoute dynamique du Provider
    final adminProvider = context.watch<AdminDashboardProvider>();
    final data = adminProvider.dashboardData;
    final financialDyn = data?.financialOverview as dynamic;

    // Récupération sécurisée du montant des cotisations collectées
    num rawContributions = 0;
    if (financialDyn != null) {
      try {
        rawContributions =
            financialDyn.contributionsCollected ??
            financialDyn.monthlyCollected ??
            0;
      } catch (_) {
        rawContributions = 0;
      }
    }

    final String formattedAmount = rawContributions.toStringAsFixed(0);

    return _buildStatCard(
      title: "Cotisations perçues",
      value: "$formattedAmount XAF",
      icon: Icons.payments_rounded,
      color: greenPrimary,
      bgGradient: const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
      actionWidget: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: greenPrimary,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: goldAccent, width: 0.5),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_rounded, size: 14, color: goldAccent),
              SizedBox(width: 2),
              Text(
                "Voir",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required List<Color> bgGradient,
    Widget? actionWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              if (actionWidget != null) actionWidget,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
