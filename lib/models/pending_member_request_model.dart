class PendingMemberRequest {
  final int id;
  final String fullName;
  final String? avatarUrl;
  final String positionOrPhone;
  final String requestDate;

  PendingMemberRequest({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.positionOrPhone,
    required this.requestDate,
  });

  factory PendingMemberRequest.fromJson(Map<String, dynamic> json) {
    // Conversion sécurisée de l'ID (au cas où il arrive sous forme de String)
    final parsedId = json['id'] is int
        ? json['id']
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;

    // Récupération et formatage sécurisé de la date (ex: "2026-05-20T10:00:00.000Z" -> "2026-05-20")
    String rawDate =
        json['created_at'] ?? json['request_date'] ?? json['date'] ?? '';
    if (rawDate.contains('T')) {
      rawDate = rawDate.split('T').first;
    }

    return PendingMemberRequest(
      id: parsedId,
      fullName:
          json['fullName'] ?? json['full_name'] ?? json['name'] ?? 'Membre VSM',
      avatarUrl:
          json['avatarUrl'] ??
          json['avatar_url'] ??
          json['profile_photo_path'] ??
          json['profile_photo_url'],
      positionOrPhone:
          json['positionOrPhone'] ??
          json['phone'] ??
          json['phone_number'] ??
          json['position'] ??
          'Joueur',
      requestDate: rawDate.isNotEmpty ? rawDate : 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone': positionOrPhone,
      'created_at': requestDate,
    };
  }
}
