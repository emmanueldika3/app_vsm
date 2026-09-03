// lib/models/admin_dashboard_model.dart

// ==========================================
// 1. MODÈLES DASHBOARD ADMINISTRATEUR
// ==========================================

class AdminDashboardModel {
  final MembersOverview membersOverview;
  final FinancialOverview financialOverview;
  final EventsOverview eventsOverview;

  AdminDashboardModel({
    required this.membersOverview,
    required this.financialOverview,
    required this.eventsOverview,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return AdminDashboardModel(
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
  final int newThisMonth;

  MembersOverview({
    required this.totalMembers,
    required this.activeMembers,
    required this.newThisMonth,
  });

  factory MembersOverview.fromJson(Map<String, dynamic> json) {
    return MembersOverview(
      totalMembers: (json['total_members'] as num?)?.toInt() ?? 0,
      activeMembers: (json['active_members'] as num?)?.toInt() ?? 0,
      newThisMonth: (json['new_this_month'] as num?)?.toInt() ?? 0,
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
      totalCollected: (json['total_collected'] as num?)?.toDouble() ?? 0.0,
      collectedThisMonth:
          (json['collected_this_month'] as num?)?.toDouble() ?? 0.0,
      pendingThisMonth: (json['pending_this_month'] as num?)?.toDouble() ?? 0.0,
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
      upcomingEvents: (json['upcoming_events'] as num?)?.toInt() ?? 0,
      totalEventsThisYear:
          (json['total_events_this_year'] as num?)?.toInt() ?? 0,
      averageAttendanceRate:
          json['average_attendance_rate']?.toString() ?? '0%',
    );
  }
}

// ==========================================
// 2. MODÈLES DASHBOARD JOUEUR / MEMBRE
// ==========================================

class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String? date;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.date,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      date: json['date'],
    );
  }
}

class MatchModel {
  final String id;
  final String opponent;
  final String date;
  final String location;

  MatchModel({
    required this.id,
    required this.opponent,
    required this.date,
    required this.location,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id']?.toString() ?? '',
      opponent: json['opponent'] ?? '',
      date: json['date'] ?? '',
      location: json['location'] ?? '',
    );
  }
}

class FinancialSummaryModel {
  final double totalCollected;
  final double pendingAmount;

  FinancialSummaryModel({
    required this.totalCollected,
    required this.pendingAmount,
  });

  factory FinancialSummaryModel.fromJson(Map<String, dynamic> json) {
    return FinancialSummaryModel(
      totalCollected: (json['total_collected'] as num?)?.toDouble() ?? 0.0,
      pendingAmount: (json['pending_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
