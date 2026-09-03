// lib/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:vsm_app/widgets/announcements_widget.dart';
import 'package:vsm_app/widgets/admin_dashboard_section.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // Titre principal
          Text(
            "Tableau de bord Administrateur",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E5235),
            ),
          ),
          SizedBox(height: 16),

          // 1. Widget d'Annonces au-dessus
          AnnouncementsWidget(),
          SizedBox(height: 24),

          // 2. Widget de Statistiques & Cartes en dessous
          AdminStatsWidget(),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
