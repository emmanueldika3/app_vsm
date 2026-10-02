import 'package:flutter/material.dart';
import 'package:vsm_app/widgets/coach/overview_tab_widget.dart';
import 'package:vsm_app/widgets/coach/tactics_tab_widget.dart';
import 'package:vsm_app/widgets/coach/squad_tab_widget.dart';
import 'package:vsm_app/widgets/coach/finances_com_tab_widget.dart';
import 'package:vsm_app/models/event_model.dart';

class CoachDashboardScreen extends StatelessWidget {
  final EventModel event; // Reçoit l'événement sélectionné

  const CoachDashboardScreen({super.key, required this.event});

  // Couleurs de la charte VSM FC
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color greenDark = Color(0xFF0A1E13);
  static const Color bordeauxRed = Color(0xFF6B1D2F);
  static const Color goldAccent = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: greenPrimary,
          elevation: 2,
          toolbarHeight: 46,
          title: Text(
            "Tableau de bord Coach - ${event.title}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: TabBar(
              isScrollable: true,
              indicatorColor: goldAccent,
              indicatorWeight: 2.5,
              labelColor: goldAccent,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              tabs: const [
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
                      Icon(Icons.sports_soccer_outlined, size: 18),
                      SizedBox(width: 6),
                      Text('Tactique'),
                    ],
                  ),
                ),
                Tab(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.groups_outlined, size: 18),
                      SizedBox(width: 6),
                      Text('Effectif'),
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
                      Text('Finances & Com'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // 1. Vue d'ensemble
            const OverviewTabWidget(),

            // 2. Tactique
            const TacticalTabWidget(),

            // 3. Effectif (Transmission de l'événement au SquadTabWidget)
            SquadTabWidget(event: event),

            // 4. Finances & Com
            const FinancesComTabWidget(),
          ],
        ),
      ),
    );
  }
}
