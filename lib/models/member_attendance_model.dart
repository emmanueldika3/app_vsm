class MemberAttendanceModel {
  final double attendanceRate;
  final int presentCount;
  final int absentCount;
  final List<EventAttendanceHistory> history;

  MemberAttendanceModel({
    required this.attendanceRate,
    required this.presentCount,
    required this.absentCount,
    required this.history,
  });

  factory MemberAttendanceModel.fromJson(Map<String, dynamic> json) {
    var historyList = json['history'] as List? ?? [];
    List<EventAttendanceHistory> parsedHistory = historyList
        .map((item) => EventAttendanceHistory.fromJson(item))
        .toList();

    return MemberAttendanceModel(
      attendanceRate: (json['attendance_rate'] ?? 0.0).toDouble(),
      presentCount: json['present_count'] ?? 0,
      absentCount: json['absent_count'] ?? 0,
      history: parsedHistory,
    );
  }
}

class EventAttendanceHistory {
  final String title;
  final String date;
  final String status;
  final String type;

  EventAttendanceHistory({
    required this.title,
    required this.date,
    required this.status,
    required this.type,
  });

  factory EventAttendanceHistory.fromJson(Map<String, dynamic> json) {
    return EventAttendanceHistory(
      title: json['title'] ?? json['opponent'] ?? 'Événement',
      date: json['date'] ?? '',
      status: json['status'] ?? 'Inconnu',
      type: json['type'] ?? json['category'] ?? 'Match / Entraînement',
    );
  }
}
