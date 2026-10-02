class SquadMember {
  final int id;
  final String name;
  final String number;
  final String position;
  String status; // "present", "absent", "uncertain"
  final int totalEvents;
  final int presentCount;
  final int absentCount;
  final List<dynamic> history;

  SquadMember({
    required this.id,
    required this.name,
    required this.number,
    required this.position,
    required this.status,
    required this.totalEvents,
    required this.presentCount,
    required this.absentCount,
    required this.history,
  });

  /// Getter calculé automatiquement pour éviter les erreurs d'attribut manquant
  double get attendanceRate {
    if (totalEvents == 0) return 0.0;
    return (presentCount / totalEvents) * 100;
  }

  factory SquadMember.fromJson(Map<String, dynamic> json) {
    return SquadMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['full_name'] ?? 'Inconnu',
      number: json['number']?.toString() ?? '',
      position: json['position'] ?? 'Milieu',
      status: json['pivot']?['status'] ?? json['status'] ?? 'uncertain',
      totalEvents: json['total_events'] ?? 0,
      presentCount: json['present_count'] ?? 0,
      absentCount: json['absent_count'] ?? 0,
      history: json['history'] ?? [],
    );
  }
}
