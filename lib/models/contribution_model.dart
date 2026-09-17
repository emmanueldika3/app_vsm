class ContributionModel {
  final int id;
  final int? userId;
  final double amount;
  final String type; // ex: 'cotisation'
  final String status; // 'paid', 'pending', 'late'
  final DateTime? paidAt;
  final DateTime? createdAt;
  final UserBasic? user; // Données du membre si jointes avec with('user')

  ContributionModel({
    required this.id,
    this.userId,
    required this.amount,
    required this.type,
    required this.status,
    this.paidAt,
    this.createdAt,
    this.user,
  });

  factory ContributionModel.fromJson(Map<String, dynamic> json) {
    return ContributionModel(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      amount: (json['amount'] as num).toDouble(),
      type: (json['type'] as String?) ?? 'cotisation',
      status: (json['status'] as String?) ?? 'pending',
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      user: json['user'] != null ? UserBasic.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'status': status,
      'paid_at': paidAt?.toIso8601String(),
    };
  }

  // Helpers de statut de paiement
  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isLate => status == 'late';
}

class UserBasic {
  final int id;
  final String name;
  final String? email;

  UserBasic({required this.id, required this.name, this.email});

  factory UserBasic.fromJson(Map<String, dynamic> json) {
    return UserBasic(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
    );
  }
}
