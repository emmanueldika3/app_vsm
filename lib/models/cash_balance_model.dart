class CashBalanceModel {
  final double totalBalance;
  final String currency;

  CashBalanceModel({required this.totalBalance, this.currency = 'XAF'});

  factory CashBalanceModel.fromJson(Map<String, dynamic> json) {
    // Si la clé 'data' existe et est un Map, on descend dedans
    final Map<String, dynamic> body = (json['data'] is Map<String, dynamic>)
        ? json['data']
        : json;

    return CashBalanceModel(
      totalBalance: (body['total_balance'] as num?)?.toDouble() ?? 0.0,
      currency: body['currency']?.toString() ?? 'XAF',
    );
  }
}
