import 'package:flutter/material.dart';
import '../models/user_model.dart'; // Ajuste le chemin si besoin

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;

  // --- LISTE DES UTILISATEURS DE TEST PAR RÔLE ---
  static List<UserModel> _mockUsers = [
    UserModel(
      id: '1',
      fullName: 'Capitaine VSM',
      phone: '690000001',
      password: '123',
      role: UserRole.admin,
    ),
    UserModel(
      id: '2',
      fullName: 'Emmanuel Dika',
      phone: '690000002',
      password: '1234',
      role: UserRole.player,
    ),
    UserModel(
      id: '3',
      fullName: 'Trésorier Mahèn',
      phone: '690000003',
      password: '12345',
      role: UserRole.treasurer,
    ),
  ];

  // Nettoyage ultra-sécurisé du numéro : ne garde que les 9 derniers chiffres
  String _cleanPhoneDigits(String rawPhone) {
    // Extrait uniquement les chiffres
    final digitsOnly = rawPhone.replaceAll(RegExp(r'\D'), '');

    // Si le numéro commence par 237 et fait plus de 9 chiffres (ex: 237690000002)
    if (digitsOnly.length > 9 && digitsOnly.startsWith('237')) {
      return digitsOnly.substring(digitsOnly.length - 9);
    }

    return digitsOnly;
  }

  // --- LOGIQUE DE CONNEXION ---
  Future<bool> login(String rawPhone, String rawPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulation de délai réseau
    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      final inputPhone = _cleanPhoneDigits(rawPhone);
      final inputPassword = rawPassword.trim();

      debugPrint(
        "--> Tentative de connexion avec : phone='$inputPhone', password='$inputPassword'",
      );

      UserModel? matchedUser;

      for (final u in _mockUsers) {
        final mockPhone = _cleanPhoneDigits(u.phone);
        final mockPassword = u.password.trim();

        if (mockPhone == inputPhone && mockPassword == inputPassword) {
          matchedUser = u;
          break;
        }
      }

      if (matchedUser != null) {
        _currentUser = matchedUser;
        _isLoading = false;
        _errorMessage = null;
        debugPrint(
          "--> Succès : Connecté en tant que ${matchedUser.fullName} (${matchedUser.role})",
        );
        notifyListeners();
        return true;
      } else {
        _currentUser = null;
        _isLoading = false;
        _errorMessage = "Numéro ou mot de passe incorrect.";
        debugPrint("--> Échec : Identifiants non trouvés");
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("--> CRASH LOGIN : $e");
      debugPrint("--> STACKTRACE : $stackTrace");

      _currentUser = null;
      _isLoading = false;
      _errorMessage =
          "Erreur système : $e"; // Affiche l'erreur exacte sur l'écran pour debug
      notifyListeners();
      return false;
    }
  }

  // --- DÉCONNEXION ---
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}
