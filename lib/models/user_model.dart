// Dans lib/models/user_model.dart

enum UserRole { admin, player, treasurer, president, coach }

class UserModel {
  final String id;
  final String fullName;
  final String phone;
  final String password;
  final UserRole role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.password,
    required this.role,
  });

  // 🟢 GETTER POUR OBTENIR LE TEXTE DU RÔLE
  String get roleTitle {
    switch (role) {
      case UserRole.admin:
        return 'Capitaine / Admin';
      case UserRole.treasurer:
        return 'Trésorier';
      case UserRole.player:
      default:
        return 'Joueur VSM PK11';
    }
  }
}
