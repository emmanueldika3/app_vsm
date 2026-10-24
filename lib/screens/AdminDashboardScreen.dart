import 'package:flutter/material.dart';

// Importez votre widget de vue d'ensemble (ajustez le chemin si nécessaire)
import 'package:vsm_app/widgets/coach/overview_tab_widget.dart';
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
      length: 4, // Passage à 4 onglets
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
              isScrollable:
                  true, // Recommandé pour 4 onglets et plus afin d'éviter le débordement
              indicatorColor: goldAccent,
              indicatorWeight: 2.5,
              labelColor: goldAccent,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              // Espacement ajusté pour les onglets
              labelPadding: EdgeInsets.symmetric(horizontal: 12),
              tabs: [
                Tab(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dashboard_outlined, size: 18),
                      SizedBox(width: 6),
                      Text("Vue d'ensemble"),
                    ],
                  ),
                ),
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
            // 1. Nouvel onglet : Vue d'ensemble
            OverviewTabWidget(),

            // 2. Widget de l'onglet Finances
            FinancialTabWidget(),

            // 3. Widget de l'onglet Membres
            MembersTabWidget(),

            // 4. Widget de l'onglet Communication
            CommunicationTabWidget(),
          ],
        ),
      ),
    );
  }
}
