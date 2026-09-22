import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';
import 'package:vsm_app/provider/auth_provider.dart';
import 'package:vsm_app/widgets/active_members_card.dart';
import 'package:vsm_app/widgets/pending_requests_card.dart';
import 'package:vsm_app/widgets/pending_member_request_widget.dart';
import 'package:vsm_app/widgets/ActiveMembersListWidget.dart';

class MembersTabWidget extends StatelessWidget {
  const MembersTabWidget({super.key});

  static const Color greenPrimary = Color(0xFF184332);
  static const Color bordeauxRed = Color(0xFF6B1D2F);

  @override
  Widget build(BuildContext context) {
    // 1. Récupération des données du dashboard
    final dashboardProvider = Provider.of<AdminDashboardProvider>(context);

    // 2. Récupération du token depuis AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final String token = authProvider.token ?? '';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gestion des membres",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: greenPrimary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
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

          // 1. Cartes KPIs
          const Row(
            children: [
              Expanded(child: ActiveMembersCard()),
              SizedBox(width: 12),
              Expanded(child: PendingRequestsCard()),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Section prioritaire : Demandes d'adhésion en attente
          if (dashboardProvider.isLoadingPendingMembers)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: greenPrimary),
              ),
            )
          else if (dashboardProvider.pendingMemberRequests.isEmpty)
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    "Aucune demande d'adhésion en attente.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            const PendingRequestsView(),

          const SizedBox(height: 20),

          // 3. Section Annuaire & Rôles
          const Text(
            "Attribution des Rôles & Annuaire",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: greenPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Appel corrigé : retrait de 'const' et passage du token dynamique
          ActiveMembersListWidget(token: token),
        ],
      ),
    );
  }
}
