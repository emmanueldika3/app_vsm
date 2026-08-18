enum UserRole { player, coach, treasurer, president }

enum AttendanceStatus { pending, present, absent, uncertain }

class User {
  final String id;
  final String name;
  final UserRole role;
  final bool isUpToDateWithDues; // Cotisation à jour ?

  User({
    required this.id,
    required this.name,
    required this.role,
    this.isUpToDateWithDues = true,
  });
}

class Match {
  final String id;
  final String opponent;
  final DateTime dateTime;
  final String location;
  final Map<String, AttendanceStatus> attendances; // userId -> status

  Match({
    required this.id,
    required this.opponent,
    required this.dateTime,
    required this.location,
    required this.attendances,
  });

  // Calcul dynamique des présents
  int get presentCount => attendances.values
      .where((status) => status == AttendanceStatus.present)
      .length;
}
