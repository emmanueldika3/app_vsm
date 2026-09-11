class CollectedContributionsModel {
  final double totalCollected;
  final String currency;
  final int contributionsCount;

  CollectedContributionsModel({
    required this.totalCollected,
    this.currency = 'XAF',
    required this.contributionsCount,
  });

  factory CollectedContributionsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        (json.containsKey('data') && json['data'] is Map<String, dynamic>)
        ? json['data']
        : json;

    return CollectedContributionsModel(
      totalCollected: (data['total_collected'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency']?.toString() ?? 'XAF',
      contributionsCount: (data['contributions_count'] as num?)?.toInt() ?? 0,
    );
  }
}
