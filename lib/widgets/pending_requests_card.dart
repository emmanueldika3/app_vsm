// lib/widgets/cards/pending_requests_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';

class PendingRequestsCard extends StatelessWidget {
  final VoidCallback? onTap;

  const PendingRequestsCard({super.key, this.onTap});

  static const Color bordeauxRed = Color(0xFF6B1D2F);

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminDashboardProvider>();
    final data = adminProvider.dashboardData;
    final membersDyn = data?.membersOverview as dynamic;

    // Correctif : fallback sécurisé sur `newThisMonth` ou 0 si `pendingRequests` n'existe pas dans le modèle
    int rawPendingCount = 0;
    if (membersDyn != null) {
      try {
        rawPendingCount =
            membersDyn.newThisMonth ?? membersDyn.pendingRequests ?? 0;
      } catch (_) {
        // En cas d'accès dynamique à une propriété inexistante
        rawPendingCount = 0;
      }
    }

    final String pendingCount = rawPendingCount.toString().padLeft(2, '0');

    return _buildStatCard(
      title: "Demandes en attente",
      value: pendingCount,
      icon: Icons.hourglass_top_rounded,
      color: bordeauxRed,
      bgGradient: const [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
      actionWidget: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bordeauxRed,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFD4AF37), width: 0.5),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.visibility_rounded,
                size: 14,
                color: Color(0xFFD4AF37),
              ),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
