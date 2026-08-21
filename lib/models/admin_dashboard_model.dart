class AdminDashboardData {
  final int activeMembers;
  final int pendingMembersCount;
  final double clubBalance;
  final double contributionRate;
  final List<PendingMember> pendingMembers;
  final FinancialSummary financialSummary;

  AdminDashboardData({
    required this.activeMembers,
    required this.pendingMembersCount,
    required this.clubBalance,
    required this.contributionRate,
    required this.pendingMembers,
    required this.financialSummary,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardData(
      activeMembers: json['active_members'] ?? 0,
      pendingMembersCount: json['pending_members_count'] ?? 0,
      clubBalance: (json['club_balance'] ?? 0).toDouble(),
      contributionRate: (json['contribution_rate'] ?? 0).toDouble(),
      pendingMembers: (json['pending_members'] as List? ?? [])
          .map((m) => PendingMember.fromJson(m))
          .toList(),
      financialSummary: FinancialSummary.fromJson(
        json['financial_summary'] ?? {},
      ),
    );
  }
}

class PendingMember {
  final int id;
  final String name;
  final String position;
  final String createdAt;

  PendingMember({
    required this.id,
    required this.name,
    required this.position,
    required this.createdAt,
  });

  factory PendingMember.fromJson(Map<String, dynamic> json) {
    return PendingMember(
      id: json['id'],
      name: json['name'] ?? '',
      position: json['position'] ?? 'Non spécifié',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class FinancialSummary {
  final int paidCount;
  final int totalCount;
  final double totalIncome;
  final double totalExpenses;

  FinancialSummary({
    required this.paidCount,
    required this.totalCount,
    required this.totalIncome,
    required this.totalExpenses,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      paidCount: json['paid_count'] ?? 0,
      totalCount: json['total_count'] ?? 0,
      totalIncome: (json['total_income'] ?? 0).toDouble(),
      totalExpenses: (json['total_expenses'] ?? 0).toDouble(),
    );
  }
}
