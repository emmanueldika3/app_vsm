class ExpenseModel {
  final int id;
  final String title;
  final String? description;
  final double amount;
  final String status;
  final int? approvedBy;
  final int? executedBy;
  final DateTime? approvedAt;
  final DateTime? executedAt;
  final String? rejectionReason;

  ExpenseModel({
    required this.id,
    required this.title,
    this.description,
    required this.amount,
    required this.status,
    this.approvedBy,
    this.executedBy,
    this.approvedAt,
    this.executedAt,
    this.rejectionReason,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      approvedBy: json['approved_by'] as int?,
      executedBy: json['executed_by'] as int?,
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'].toString())
          : null,
      executedAt: json['executed_at'] != null
          ? DateTime.tryParse(json['executed_at'].toString())
          : null,
      rejectionReason: json['rejection_reason']?.toString(),
    );
  }
}
