// lib/models/pending_disbursements_model.dart

class PendingDisbursementsModel {
  final double totalPending;
  final String currency;
  final int pendingCount;

  PendingDisbursementsModel({
    required this.totalPending,
    this.currency = 'XAF',
    this.pendingCount = 0,
  });

  factory PendingDisbursementsModel.fromJson(Map<String, dynamic> json) {
    // Gère la présence ou l'absence du wrapper 'data'
    final data =
        (json.containsKey('data') && json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return PendingDisbursementsModel(
      totalPending: (data['total_pending'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency']?.toString() ?? 'XAF',
      pendingCount: (data['pending_count'] as num?)?.toInt() ?? 0,
    );
  }
}
