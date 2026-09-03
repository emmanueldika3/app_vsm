class MemberStatModel {
  final int totalMembers;
  final int activeMembers;
  final int inactiveMembers;
  final int newThisMonth;

  MemberStatModel({
    required this.totalMembers,
    required this.activeMembers,
    required this.inactiveMembers,
    required this.newThisMonth,
  });

  factory MemberStatModel.fromJson(Map<String, dynamic> json) {
    // Si le JSON reçu est le bloc 'members_overview'
    final total = json['total_members'] ?? 0;
    final active = json['active_members'] ?? 0;

    return MemberStatModel(
      totalMembers: total,
      activeMembers: active,
      inactiveMembers: (total - active) < 0 ? 0 : (total - active),
      newThisMonth: json['new_this_month'] ?? 0,
    );
  }
}
