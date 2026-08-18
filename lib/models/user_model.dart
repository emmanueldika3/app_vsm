// lib/models/user_model.dart

enum UserRole { admin, player, treasurer, president, coach }

class UserModel {
  final String id;
  final String fullName;
  final String phone;
  final UserRole role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.role,
  });

  // 🟢 GETTER POUR OBTENIR LE TEXTE DU RÔLE
  String get roleTitle {
    switch (role) {
      case UserRole.admin:
        return 'Capitaine / Admin';
      case UserRole.treasurer:
        return 'Trésorier';
      case UserRole.president:
        return 'Président';
      case UserRole.coach:
        return 'Coach / Entraîneur';
      case UserRole.player:
      default:
        return 'Joueur VSM PK11';
    }
  }

  // 🟢 DESERIALISATION : Convertit la réponse JSON de Laravel en UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      fullName: json['name'] ?? json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      role: _roleFromString(json['role'] ?? 'player'),
    );
  }

  // 🟢 SERIALISATION : Convertit le UserModel en Map JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': fullName, 'phone': phone, 'role': role.name};
  }

  // Helper pour convertir la chaîne de l'API vers l'enum
  static UserRole _roleFromString(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'treasurer':
      case 'tresorier':
        return UserRole.treasurer;
      case 'president':
        return UserRole.president;
      case 'coach':
      case 'entraineur':
        return UserRole.coach;
      case 'player':
      case 'joueur':
      default:
        return UserRole.player;
    }
  }
}
