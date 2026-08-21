// lib/widgets/custom_bottom_navigation_bar.dart
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color greenPrimary = Color(0xFF1B5E20);
    const Color goldAccent = Color(0xFFFFD700);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType
          .fixed, // Indispensable pour garder les labels visibles avec 5 onglets
      backgroundColor: greenPrimary,
      selectedItemColor: goldAccent,
      unselectedItemColor: Colors.white70,
      selectedFontSize: 12,
      unselectedFontSize: 11,
      showUnselectedLabels: true,
      items: const [
        // 1. Accueil
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        // 2. Cotisation
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'Cotisation',
        ),
        // 3. Matchs
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_soccer_outlined),
          activeIcon: Icon(Icons.sports_soccer),
          label: 'Matchs',
        ),
        // 4. Annuaire
        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt_outlined),
          activeIcon: Icon(Icons.people_alt),
          label: 'Annuaire',
        ),
        // 5. Galerie
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_library_outlined),
          activeIcon: Icon(Icons.photo_library),
          label: 'Galerie',
        ),
      ],
    );
  }
}
