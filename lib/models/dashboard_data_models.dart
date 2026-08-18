class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final bool isUrgent;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.isUrgent = false,
  });
}

class MatchModel {
  final String id;
  final String opponent;
  final String location;
  final String dateString;

  MatchModel({
    required this.id,
    required this.opponent,
    required this.location,
    required this.dateString,
  });
}

class FinancialSummaryModel {
  final double monthlyFeeAmount;
  final bool isMonthlyPaid;
  final double solidarityFeeAmount;
  final bool isSolidarityPaid;

  FinancialSummaryModel({
    required this.monthlyFeeAmount,
    required this.isMonthlyPaid,
    required this.solidarityFeeAmount,
    required this.isSolidarityPaid,
  });
}

class AlbumModel {
  final String id;
  final String title;
  final String? coverUrl;

  AlbumModel({required this.id, required this.title, this.coverUrl});

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      coverUrl: json['cover_url'],
    );
  }
}
