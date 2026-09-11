class ExecutedDisbursementsModel {
  final double totalExecuted;
  final String currency;
  final int executedCount;

  ExecutedDisbursementsModel({
    required this.totalExecuted,
    this.currency = 'XAF',
    required this.executedCount,
  });

  factory ExecutedDisbursementsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        (json.containsKey('data') && json['data'] is Map<String, dynamic>)
        ? json['data']
        : json;

    return ExecutedDisbursementsModel(
      totalExecuted: (data['total_executed'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency']?.toString() ?? 'XAF',
      executedCount: (data['executed_count'] as num?)?.toInt() ?? 0,
    );
  }
}
