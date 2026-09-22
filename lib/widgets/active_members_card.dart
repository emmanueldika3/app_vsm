// lib/widgets/cards/active_members_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';
import 'package:vsm_app/provider/auth_provider.dart';
import 'package:vsm_app/widgets/AjouterMembre.dart';

class ActiveMembersCard extends StatelessWidget {
  final VoidCallback? onUserAdded;

  const ActiveMembersCard({super.key, this.onUserAdded});

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminDashboardProvider>();

    // État de chargement
    final bool isLoading =
        adminProvider.isLoadingActiveMembers || adminProvider.isLoadingData;

    // Récupération multi-sources et sécurisée du nombre
    int rawActiveCount = 0;

    // Priorité 1 : Liste activeMembers si elle contient des éléments
    if (adminProvider.activeMembers.isNotEmpty) {
      rawActiveCount = adminProvider.activeMembers.length;
    } else {
      // Priorité 2 : Recherche dynamique dans dashboardData.membersOverview
      final dynamic overview = adminProvider.dashboardData?.membersOverview;

      if (overview != null) {
        if (overview is Map<String, dynamic>) {
          rawActiveCount =
              (overview['active_members'] ??
                      overview['activeMembers'] ??
                      overview['count'] ??
                      0)
                  as int;
        } else {
          try {
            // Dans le cas d'un objet modèle avec getter
            rawActiveCount = (overview.activeMembers as num?)?.toInt() ?? 0;
          } catch (_) {
            rawActiveCount = adminProvider.activeMembersCount;
          }
        }
      }
    }

    final String activeMembersText = rawActiveCount.toString().padLeft(2, '0');

    // Couleurs de la charte VSM
    const primaryColor = Color(0xFF184332);
    const accentGold = Color(0xFFD4AF37);
    const Color greenPrimary = Color(0xFF1E5235);
    const Color greenDark = Color(0xFF0A1E13);
    const Color bordeauxRed = Color(0xFF6B1D2F);

    return _buildCard(
      title: "Membres Actifs",
      value: activeMembersText,
      isLoading: isLoading,
      icon: Icons.people_alt_rounded,
      color: primaryColor,
      bgGradient: [
        primaryColor.withOpacity(0.15),
        primaryColor.withOpacity(0.09),
      ],
      actionWidget: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (dialogContext) {
                return AddUserDialog(
                  onSuccess: () async {
                    final String? token = context.read<AuthProvider>().token;

                    if (token != null && context.mounted) {
                      await Future.wait([
                        context
                            .read<AdminDashboardProvider>()
                            .fetchDashboardData(token),
                        context
                            .read<AdminDashboardProvider>()
                            .fetchActiveMembers(token),
                      ]);
                    }

                    if (onUserAdded != null) {
                      onUserAdded!();
                    }
                  },
                );
              },
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentGold, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 14, color: accentGold),
                SizedBox(width: 3),
                Text(
                  "Ajouter",
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
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required bool isLoading,
    required IconData icon,
    required Color color,
    required List<Color> bgGradient,
    Widget? actionWidget,
  }) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: bgGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (actionWidget != null) actionWidget,
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading)
                const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF184332),
                    ),
                  ),
                )
              else
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF184332),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
