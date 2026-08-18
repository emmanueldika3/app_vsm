import 'package:flutter/material.dart';
import '../models/app_models.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  // Helpers pour vérifier rapidement le rôle dans l'UI
  bool get isCoach =>
      _currentUser?.role == UserRole.coach ||
      _currentUser?.role == UserRole.president;
  bool get isTreasurer =>
      _currentUser?.role == UserRole.treasurer ||
      _currentUser?.role == UserRole.president;

  // Simulation de connexion
  Future<void> login(String userId) async {
    _isLoading = true;
    notifyListeners();

    // Simuler un appel API (ex: Laravel Backend)
    await Future.delayed(const Duration(seconds: 1));

    // Utilisateur de test (à remplacer par votre appel API)
    _currentUser = User(
      id: userId,
      name: 'Marc Emmanuel',
      role: UserRole
          .coach, // Essayez de changer le rôle pour tester les dashboards
      isUpToDateWithDues: true,
    );

    _isLoading = false;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
