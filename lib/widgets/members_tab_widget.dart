import 'package:flutter/material.dart';
import 'package:vsm_app/widgets/active_members_card.dart';
import 'package:vsm_app/widgets/pending_requests_card.dart';

class MembersTabWidget extends StatelessWidget {
  const MembersTabWidget({super.key});

  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color bordeauxRed = Color(0xFF6B1D2F);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre d'aperçu général
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

          // 1. Alignement des cartes KPIs autonomes
          const Row(
            children: [
              Expanded(child: ActiveMembersCard()),
              SizedBox(width: 12),
              Expanded(child: PendingRequestsCard()),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Section Annuaire & Rôles
          const Text(
            "Attribution des Rôles",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: greenPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Emplacement pour le tableau/liste des membres
        ],
      ),
    );
  }
}
