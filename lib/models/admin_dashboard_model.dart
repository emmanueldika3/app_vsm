// lib/models/admin_dashboard_data.dart

class AdminDashboardData {
  final MembersOverview membersOverview;
  final FinancialOverview financialOverview;
  final EventsOverview eventsOverview;

  AdminDashboardData({
    required this.membersOverview,
    required this.financialOverview,
    required this.eventsOverview,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    // Extraction du nœud 'data' s'il est imbriqué dans la réponse API
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return AdminDashboardData(
      membersOverview: MembersOverview.fromJson(
        data['members_overview'] as Map<String, dynamic>? ?? {},
      ),
      financialOverview: FinancialOverview.fromJson(
        data['financial_overview'] as Map<String, dynamic>? ?? {},
      ),
      eventsOverview: EventsOverview.fromJson(
        data['events_overview'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class MembersOverview {
  final int totalMembers;
  final int activeMembers;
  final int inactiveMembers;
  final int newThisMonth;

  MembersOverview({
    required this.totalMembers,
    required this.activeMembers,
    required this.inactiveMembers,
    required this.newThisMonth,
  });

  factory MembersOverview.fromJson(Map<String, dynamic> json) {
    final total = json['total_members'] ?? 0;
    final active = json['active_members'] ?? 0;

    return MembersOverview(
      totalMembers: total,
      activeMembers: active,
      inactiveMembers: (total - active) < 0 ? 0 : (total - active),
      newThisMonth: json['new_this_month'] ?? 0,
    );
  }
}

class FinancialOverview {
  final double totalCollected;
  final double collectedThisMonth;
  final double pendingThisMonth;

  FinancialOverview({
    required this.totalCollected,
    required this.collectedThisMonth,
    required this.pendingThisMonth,
  });

  factory FinancialOverview.fromJson(Map<String, dynamic> json) {
    return FinancialOverview(
      totalCollected: (json['total_collected'] ?? 0).toDouble(),
      collectedThisMonth: (json['collected_this_month'] ?? 0).toDouble(),
      pendingThisMonth: (json['pending_this_month'] ?? 0).toDouble(),
    );
  }
}

class EventsOverview {
  final int upcomingEvents;
  final int totalEventsThisYear;
  final String averageAttendanceRate;

  EventsOverview({
    required this.upcomingEvents,
    required this.totalEventsThisYear,
    required this.averageAttendanceRate,
  });

  factory EventsOverview.fromJson(Map<String, dynamic> json) {
    return EventsOverview(
      upcomingEvents: json['upcoming_events'] ?? 0,
      totalEventsThisYear: json['total_events_this_year'] ?? 0,
      averageAttendanceRate: json['average_attendance_rate'] ?? '0%',
    );
  }
}
