import 'package:flutter/material.dart';
import 'package:vsm_app/screens/AdminDashboardScreen.dart';
import 'package:vsm_app/widgets/vsm_app_bar.dart';
import 'package:vsm_app/widgets/MemberProfileCard.dart';
import 'package:vsm_app/widgets/custom_bottom_navigation_bar.dart';

// Écrans des onglets
// import 'package:vsm_app/screens/homeScreen.dart';
import 'package:vsm_app/screens/CotisationsScreen.dart';
import 'package:vsm_app/screens/matchScreen.dart';
import 'package:vsm_app/screens/annuaireScreen.dart';
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

  // Liste des sous-écrans
  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    CotisationsScreen(),
    MatchsScreen(),
    AnnuaireScreen(),
    GalerieScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: VsmAppBar(
        userRole: 'ADMIN',
        hasUnreadNotifications: true,
        onRefresh: () {},
        onNotificationPressed: () {},
        onSettingsPressed: () {},
        onLogoutPressed: () {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Composant 1 : Carte de profil membre (fixe en haut)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: MemberProfileCard(
                onViewFullProfile: () {
                  Navigator.of(context).pushNamed('/profile');
                },
                onEditPhoto: () {},
              ),
            ),

            // Composant 2 : Onglet actif (dynamique, prend tout l'espace restant)
            Expanded(
              child: IndexedStack(index: _currentIndex, children: _screens),
            ),
          ],
        ),
      ),
      // Composant 3 : Bottom Navigation Bar (fixe en bas)
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
