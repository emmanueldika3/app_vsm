import 'package:flutter/material.dart';

import 'package:vsm_app/widgets/finances_tab_widget.dart';
import 'package:vsm_app/widgets/members_tab_widget.dart';
import 'package:vsm_app/widgets/communication_tab_widget.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  // Couleurs de la charte VSM
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color greenDark = Color(0xFF0A1E13);
  static const Color bordeauxRed = Color(0xFF6B1D2F);
  static const Color goldAccent = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: greenPrimary,
          elevation: 2,
          // Réduction de la hauteur de la barre de titre
          toolbarHeight: 46,
          title: const Text(
            "Tableau de bord Administrateur",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          bottom: const PreferredSize(
            // Hauteur réduite sur mesure pour la barre d'onglets
            preferredSize: Size.fromHeight(40),
            child: TabBar(
              indicatorColor: goldAccent,
              indicatorWeight: 2.5,
              labelColor: goldAccent,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              // Réduction des marges internes des onglets
              labelPadding: EdgeInsets.symmetric(horizontal: 4),
              tabs: [
                Tab(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 18),
                      SizedBox(width: 6),
                      Text('Finances'),
                    ],
                  ),
                ),
                Tab(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_alt_outlined, size: 18),
                      SizedBox(width: 6),
                      Text('Membres'),
                    ],
                  ),
                ),
                Tab(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.campaign_outlined, size: 18),
                      SizedBox(width: 6),
                      Text('Communication'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            // 1. Widget de l'onglet Finances
            FinancialTabWidget(),

            // 2. Widget de l'onglet Membres
            MembersTabWidget(),

            // 3. Widget de l'onglet Communication
            CommunicationTabWidget(),
          ],
        ),
      ),
    );
  }
}
