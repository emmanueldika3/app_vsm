import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vsm_app/widgets/coach/overview_tab_widget.dart';
import 'package:vsm_app/widgets/coach/tactics_tab_widget.dart';
import 'package:vsm_app/widgets/coach/squad_tab_widget.dart';
import 'package:vsm_app/widgets/coach/finances_com_tab_widget.dart';
import 'package:vsm_app/models/event_model.dart';

class CoachDashboardScreen extends StatefulWidget {
  final EventModel event;

  const CoachDashboardScreen({super.key, required this.event});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen>
    with SingleTickerProviderStateMixin {
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color goldAccent = Color(0xFFD4AF37);

  late EventModel _activeEvent;

  @override
  void initState() {
    super.initState();
    _activeEvent = widget.event;
  }

  @override
  Widget build(BuildContext context) {
    final currentEvent = _activeEvent;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: greenPrimary,
          elevation: 2,
          toolbarHeight: 46,
          automaticallyImplyLeading: false,
          titleSpacing: 16.0,
          title: Text(
            "Tableau de bord Coach - ${currentEvent.title}",
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
            const OverviewTabWidget(),
            const TacticalTabWidget(),
            SquadTabWidget(event: currentEvent),
            // 4ème Onglet structuré en 2 sous-onglets : Finance et Communication
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    color: greenPrimary.withOpacity(0.95),
                    child: TabBar(
                      indicatorColor: goldAccent,
                      indicatorWeight: 2.5,
                      labelColor: goldAccent,
                      unselectedLabelColor: Colors.white70,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      tabs: const [
                        Tab(
                          height: 38,
                          icon: Icon(Icons.account_balance_wallet, size: 16),
                          text: 'Finance',
                        ),
                        Tab(
                          height: 38,
                          icon: Icon(Icons.campaign, size: 16),
                          text: 'Communication',
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        // Sous-onglet 1 : Finances
                        FinancesComTabWidget(),

                        // Sous-onglet 2 : Communication
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
