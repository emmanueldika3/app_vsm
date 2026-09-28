class Announcement {
  final int id;
  final int authorId;
  final String title;
  final String content;
  final String category; // 'training', 'meeting', 'match', 'general'
  final String targetAudience; // 'all', 'board'
  final bool isUrgent;
  final DateTime createdAt;
  final String? authorName;

  Announcement({
    required this.id,
    required this.authorId,
    required this.title,
    required this.content,
    required this.category,
    required this.targetAudience,
    required this.isUrgent,
    required this.createdAt,
    this.authorName,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      authorId: json['author_id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      targetAudience: json['target_audience'],
      isUrgent: json['is_urgent'] == 1 || json['is_urgent'] == true,
      createdAt: DateTime.parse(json['created_at']),
      authorName: json['author'] != null ? json['author']['name'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'target_audience': targetAudience,
      'is_urgent': isUrgent,
    };
  }
}
