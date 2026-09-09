class ExecutedDisbursementsModel {
  final double totalExecuted;
  final String currency;
  final int executedCount;

  ExecutedDisbursementsModel({
    required this.totalExecuted,
    this.currency = 'XAF',
    this.executedCount = 0,
  });

  /// Factory pour construire le modèle depuis la réponse JSON de l'API Laravel
  factory ExecutedDisbursementsModel.fromJson(Map<String, dynamic> json) {
    // Gestion automatique du wrapping 'data' si l'API Laravel utilise un Resource / JsonResponse avec clé 'data'
    final Map<String, dynamic> data =
        json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data']
        : json;

    return ExecutedDisbursementsModel(
      totalExecuted:
          (data['total_executed'] as num?)?.toDouble() ??
          (data['total_disbursements'] as num?)?.toDouble() ??
          0.0,
      currency: data['currency']?.toString() ?? 'XAF',
      executedCount:
          (data['executed_count'] as num?)?.toInt() ??
          (data['count'] as num?)?.toInt() ??
          0,
    );
  }

  /// Conversion du modèle vers Map JSON si besoin
  Map<String, dynamic> toJson() {
    return {
      'total_executed': totalExecuted,
      'currency': currency,
      'executed_count': executedCount,
    };
  }
}
