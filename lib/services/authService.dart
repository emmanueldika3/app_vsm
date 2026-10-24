import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../provider/auth_provider.dart';
import 'package:vsm_app/screens/PlayerDashboardScreen.dart';
import 'package:vsm_app/models/event_model.dart';
// Importez vos autres dashboards selon les rôles
import 'package:vsm_app/screens/AdminDashboardScreen.dart';
import 'package:vsm_app/provider/coach/event_provider.dart';
// import 'package:vsm_app/screens/PresidentDashboardScreen.dart';
import 'package:vsm_app/screens/CoachDashboardScreen.dart';

class LoginController {
  // Constantes de couleurs VSM
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color bordeauxRed = Color(0xFF6B1D2F);
  static const Color goldAccent = Color(0xFFD4AF37);

  static Future<void> handleLogin({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController phoneController,
    required TextEditingController passwordController,
  }) async {
    // 1. Fermer le clavier
    FocusScope.of(context).unfocus();

    // 2. Valider le formulaire
    if (!formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 3. Exécuter la connexion
    final bool success = await authProvider.login(
      phone: phoneController.text.trim(),
      password: passwordController.text.trim(),
    );

    // Vérification contextuelle après appel async
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    if (success) {
      final user = authProvider.user;

      messenger.showSnackBar(
        SnackBar(
          backgroundColor: greenPrimary,
          content: Text(
            'Connexion réussie ! Bienvenue ${user?.fullName ?? 'au VSM'}.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // 4. Redirection dynamique basée sur le rôle
      if (user != null) {
        _navigateToRoleDashboard(context, user.role);
      }
    } else {
      final errorMsg = authProvider.errorMessage ?? 'Identifiants incorrects.';

      messenger.showSnackBar(
        SnackBar(
          backgroundColor: bordeauxRed,
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: goldAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  errorMsg,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  //  REDIRECTION SELON LE RÔLE DE L'UTILISATEUR
  static void _navigateToRoleDashboard(BuildContext context, UserRole role) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    // Récupération de l'événement dynamique depuis le provider
    final currentEvent = eventProvider.upcomingEvent;

    // Si aucun événement n'est présent, on gère l'écran selon le type attendu,
    // mais en utilisant les propriétés de l'événement récupéré s'il existe.
    Widget destinationScreen;

    switch (role) {
      case UserRole.admin:
        destinationScreen = const AdminDashboardScreen();
        break;

      case UserRole.treasurer:
        // TODO: Remplacer par TreasurerDashboardScreen()
        destinationScreen = PlayerDashboardScreen(event: currentEvent!);
        break;

      case UserRole.president:
        // TODO: Remplacer
        destinationScreen = PlayerDashboardScreen(event: currentEvent!);
        break;

      case UserRole.coach:
        destinationScreen = CoachDashboardScreen(event: currentEvent!);
        break;

      case UserRole.player:
        destinationScreen = PlayerDashboardScreen(event: currentEvent!);
        break;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => destinationScreen),
    );
  }
}
