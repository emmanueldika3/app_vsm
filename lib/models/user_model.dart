// lib/models/user_model.dart

enum UserRole { admin, player, treasurer, president, coach }

// 🟢 EXTENSION SUR L'ENUM : Libellés UI
extension UserRoleExtension on UserRole {
  /// Libellé court en majuscules pour les titres de tableaux de bord (ex: "ESPACE JOUEUR")
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'ADMINISTRATEUR';
      case UserRole.president:
        return 'PRÉSIDENT';
      case UserRole.coach:
        return 'ENTRAÎNEUR';
      case UserRole.treasurer:
        return 'TRÉSORIER';
      case UserRole.player:
      default:
        return 'JOUEUR';
    }
  }

  /// Libellé complet avec fonction/titre dans le club
  String get title {
    switch (this) {
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
}

class UserModel {
  final int id;
  final String fullName;
  final String? email;
  final String phone;
  final String? photoUrl;
  final String? position;
  final int? jerseyNumber;
  final UserRole role;
  final String status; // 'active', 'pending', 'rejected', 'suspended'
  final bool isActive;

  // Champs dynamiques relatifs aux feuilles de match / présences
  String attendanceStatus; // 'present', 'late', 'absent'
  bool isStarter;

  UserModel({
    required this.id,
    required this.fullName,
    this.email,
    required this.phone,
    this.photoUrl,
    this.position,
    this.jerseyNumber,
    required this.role,
    this.status = 'pending',
    this.isActive = false,
    this.attendanceStatus = 'absent',
    this.isStarter = false,
  });

  // 🟢 GETTERS UI & RÔLES
  String get roleName => role.name;
  String get roleTitle => role.title;
  String get roleLabel => role.label;

  // 🟢 COPYWITH
  UserModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phone,
    String? photoUrl,
    String? position,
    int? jerseyNumber,
    UserRole? role,
    String? status,
    bool? isActive,
    String? attendanceStatus,
    bool? isStarter,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      position: position ?? this.position,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      role: role ?? this.role,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      isStarter: isStarter ?? this.isStarter,
    );
  }

  // 🟢 DESERIALISATION : Parsing du JSON Laravel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      fullName: json['name'] ?? json['full_name'] ?? json['fullName'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? json['telephone'] ?? '',
      photoUrl: json['photo_url'] ?? json['avatar'] ?? json['photo'],
      position: json['position'],
      jerseyNumber: json['jersey_number'] != null
          ? int.tryParse(json['jersey_number'].toString())
          : (json['number'] != null
                ? int.tryParse(json['number'].toString())
                : null),
      role: _roleFromString(json['role']?.toString() ?? 'player'),
      status: json['status'] ?? 'pending',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      attendanceStatus:
          json['attendance']?['status'] ??
          json['attendance_status'] ??
          'absent',
      isStarter:
          json['is_starter'] ?? json['attendance']?['is_starter'] ?? false,
    );
  }

  // 🟢 SERIALISATION : Map JSON vers l'API Laravel
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': fullName,
      'email': email,
      'phone': phone,
      'photo_url': photoUrl,
      'position': position,
      'jersey_number': jerseyNumber,
      'role': role.name,
      'status': status,
      'is_active': isActive,
      'attendance_status': attendanceStatus,
      'is_starter': isStarter,
    };
  }

  // Helper de conversion chaîne API -> UserRole enum
  static UserRole _roleFromString(String roleStr) {
    final String cleanRole = roleStr.toLowerCase().trim();

    switch (cleanRole) {
      case 'admin':
        return UserRole.admin;
      case 'treasurer':
      case 'tresorier':
        return UserRole.treasurer;
      case 'president':
        return UserRole.president;
      case 'coach':
      case 'entraineur':
      case 'encadreur':
        return UserRole.coach;
      case 'player':
      case 'joueur':
      default:
        return UserRole.player;
    }
  }
}
