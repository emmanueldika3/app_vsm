class EventModel {
  final int id;
  final String title;
  final String type; // 'training' ou 'match'
  final DateTime eventDateTime;
  final String venue;
  final String? homeTeam;
  final String? awayTeam;
  final String? homeLogoUrl;
  final String? awayLogoUrl;
  final String? description;
  final String userPresence; // 'present', 'absent', 'uncertain', 'none'

  // Compteurs d'effectif
  final int presentCount;
  final int uncertainCount;
  final int absentCount;

  EventModel({
    required this.id,
    required this.title,
    required this.type,
    required this.eventDateTime,
    required this.venue,
    this.homeTeam,
    this.awayTeam,
    this.homeLogoUrl,
    this.awayLogoUrl,
    this.description,
    this.userPresence = 'none',
    this.presentCount = 0,
    this.uncertainCount = 0,
    this.absentCount = 0,
  });

  // Alias getters pour la compatibilité avec vos widgets
  int get availableCount => presentCount;
  int get unavailableCount => absentCount;

  // Calcul dynamique du temps restant avant l'événement
  Duration get timeRemaining => eventDateTime.difference(DateTime.now());

  // Badge de statut (ex: Entraînement vs Match)
  String get statusBadge =>
      type.toLowerCase() == 'match' ? 'MATCH' : 'ENTRAÎNEMENT';

  factory EventModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      final dateStr =
          json['event_date_time']?.toString() ?? json['date']?.toString() ?? '';
      parsedDate = DateTime.parse(dateStr.replaceAll(' ', 'T'));
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return EventModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? 'Événement',
      type: json['type']?.toString() ?? 'training',
      eventDateTime: parsedDate,
      venue:
          json['venue']?.toString() ??
          json['location']?.toString() ??
          'Lieu non spécifié',
      homeTeam: json['home_team']?.toString(),
      awayTeam: json['away_team']?.toString(),
      homeLogoUrl: json['home_logo_url']?.toString(),
      awayLogoUrl: json['away_logo_url']?.toString(),
      description: json['description']?.toString(),
      userPresence: json['user_presence']?.toString() ?? 'none',
      presentCount:
          int.tryParse(json['present_count']?.toString() ?? '') ??
          int.tryParse(json['available_count']?.toString() ?? '') ??
          0,
      uncertainCount:
          int.tryParse(json['uncertain_count']?.toString() ?? '') ?? 0,
      absentCount:
          int.tryParse(json['absent_count']?.toString() ?? '') ??
          int.tryParse(json['unavailable_count']?.toString() ?? '') ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'event_date_time': eventDateTime.toIso8601String(),
      'venue': venue,
      'home_team': homeTeam,
      'away_team': awayTeam,
      'home_logo_url': homeLogoUrl,
      'away_logo_url': awayLogoUrl,
      'description': description,
      'user_presence': userPresence,
      'present_count': presentCount,
      'uncertain_count': uncertainCount,
      'absent_count': absentCount,
    };
  }

  EventModel copyWith({
    int? id,
    String? title,
    String? type,
    DateTime? eventDateTime,
    String? venue,
    String? homeTeam,
    String? awayTeam,
    String? homeLogoUrl,
    String? awayLogoUrl,
    String? description,
    String? userPresence,
    int? presentCount,
    int? uncertainCount,
    int? absentCount,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      eventDateTime: eventDateTime ?? this.eventDateTime,
      venue: venue ?? this.venue,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      homeLogoUrl: homeLogoUrl ?? this.homeLogoUrl,
      awayLogoUrl: awayLogoUrl ?? this.awayLogoUrl,
      description: description ?? this.description,
      userPresence: userPresence ?? this.userPresence,
      presentCount: presentCount ?? this.presentCount,
      uncertainCount: uncertainCount ?? this.uncertainCount,
      absentCount: absentCount ?? this.absentCount,
    );
  }
}
