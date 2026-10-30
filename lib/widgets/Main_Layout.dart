import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/provider/auth_provider.dart';

import 'package:vsm_app/widgets/vsm_app_bar.dart';
import 'package:vsm_app/widgets/MemberProfileCard.dart';
import 'package:vsm_app/widgets/MemberFullProfileWidget.dart';
import 'package:vsm_app/widgets/custom_bottom_navigation_bar.dart';

import 'package:vsm_app/models/event_model.dart';

import 'package:vsm_app/screens/AdminDashboardScreen.dart';
import 'package:vsm_app/screens/CoachDashboardScreen.dart';
import 'package:vsm_app/screens/PlayerDashboardScreen.dart';
import 'package:vsm_app/screens/homeScreen.dart';

import 'package:vsm_app/screens/CotisationsScreen.dart';
import 'package:vsm_app/screens/annuaireScreen.dart';
import 'package:vsm_app/screens/matchScreen.dart';
import 'package:vsm_app/screens/galerieScreen.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Widget _getHomeWidgetByRole(dynamic rawRole) {
    if (rawRole == null) return const HomeScreen();

    final String roleStr = rawRole
        .toString()
        .split('.')
        .last
        .toLowerCase()
        .trim();

    debugPrint(">>> MainLayout - Rôle détecté pour le Dashboard : $roleStr");

    if (roleStr.contains('admin') || roleStr.contains('president')) {
      return const AdminDashboardScreen();
    }

    if (roleStr.contains('coach') ||
        roleStr.contains('encadreur') ||
        roleStr.contains('entraineur')) {
      final defaultEvent = EventModel(
        id: 1,
        title: "Prochain Match / Entraînement",
        type: "match",
        eventDateTime: DateTime.now(),
        venue: "Stade VSM",
      );
      return CoachDashboardScreen(event: defaultEvent);
    }

    if (roleStr.contains('player') ||
        roleStr.contains('joueur') ||
        roleStr.contains('veteran') ||
        roleStr.contains('treasurer') ||
        roleStr.contains('tresorier') ||
        roleStr.contains('membre') ||
        roleStr.contains('member')) {
      final defaultEvent = EventModel(
        id: 1,
        title: "Prochain Match / Entraînement",
        type: "match",
        eventDateTime: DateTime.now(),
        venue: "Stade VSM",
      );
      return PlayerDashboardScreen(event: defaultEvent);
    }

    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    // Écoute active des changements du provider d'authentification
    final authProvider = context.watch<AuthProvider>();
    final dynamic user = authProvider.user;

    final String userRole = user is Map
        ? (user['role']?.toString() ?? 'joueur')
        : (user?.role?.toString() ?? 'joueur');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: VsmAppBar(
        userRole: userRole,
        hasUnreadNotifications: true,
        onRefresh: () {},
        onNotificationPressed: () {},
        onSettingsPressed: () {},
        onLogoutPressed: () {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: MemberProfileCard(
                onViewFullProfile: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        const MemberFullProfileWidget(),
                  );
                },
                onEditPhoto: () {},
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    _getHomeWidgetByRole(userRole),
                    const CotisationsScreen(),
                    const MatchsScreen(),
                    const AnnuaireScreen(),
                    const GalerieScreen(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
