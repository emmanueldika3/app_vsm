// lib/widgets/cards/pending_disbursements_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';

class PendingDisbursementsCard extends StatelessWidget {
  final VoidCallback? onTap;

  const PendingDisbursementsCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminDashboardProvider>();
    final pendingModel = adminProvider.pendingDisbursements;
    final isLoading = adminProvider.isLoadingPendingDisbursements;

    final double rawTotal = pendingModel?.totalPending ?? 0.0;
    final String currency = pendingModel?.currency ?? 'XAF';
    final int count = pendingModel?.pendingCount ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
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
              const Icon(
                Icons.pending_actions_rounded,
                color: Color(0xFFF57F17),
                size: 24,
              ),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF57F17),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "$count",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Décaissement en Attente",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFFF57F17).withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isLoading)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF57F17)),
              ),
            )
          else
            Text(
              "${rawTotal.toStringAsFixed(0)} $currency",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF57F17),
              ),
            ),
        ],
      ),
    );
  }
}
