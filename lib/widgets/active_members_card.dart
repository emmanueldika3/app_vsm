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
    final data = adminProvider.dashboardData;
    final membersDyn = data?.membersOverview as dynamic;

    final String activeMembers = (membersDyn?.activeMembers ?? 0)
        .toString()
        .padLeft(2, '0');

    return _buildCard(
      title: "Membres Actifs",
      value: activeMembers,
      icon: Icons.people_alt_rounded,
      color: const Color(0xFF1E5235),
      bgGradient: const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
      actionWidget: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AddUserDialog(
                onSuccess: () {
                  final String? token = context.read<AuthProvider>().token;

                  if (token != null) {
                    context.read<AdminDashboardProvider>().fetchDashboardData(
                      token,
                    );
                  }

                  if (onUserAdded != null) {
                    onUserAdded!();
                  }
                },
              );
            },
          );
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E5235),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFD4AF37), width: 0.5),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 14, color: Color(0xFFD4AF37)),
              SizedBox(width: 2),
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
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
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
        border: Border.all(color: Colors.grey.shade100),
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
                  gradient: LinearGradient(colors: bgGradient),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (actionWidget != null) actionWidget,
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
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
                  fontSize: 11,
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
