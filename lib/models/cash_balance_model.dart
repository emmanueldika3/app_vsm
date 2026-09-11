class CashBalanceModel {
  final double totalBalance;
  final String currency;
  final bool isNegative;

  CashBalanceModel({
    required this.totalBalance,
    this.currency = 'XAF',
    bool? isNegative,
  }) : isNegative = isNegative ?? (totalBalance < 0);

  factory CashBalanceModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        (json.containsKey('data') && json['data'] is Map<String, dynamic>)
        ? json['data']
        : json;

    final balance = (data['total_balance'] as num?)?.toDouble() ?? 0.0;

    return CashBalanceModel(
      totalBalance: balance,
      currency: data['currency']?.toString() ?? 'XAF',
      isNegative: data['is_negative'] as bool? ?? (balance < 0),
    );
  }
}
