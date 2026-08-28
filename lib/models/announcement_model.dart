// lib/models/announcement_model.dart

class AnnouncementModel {
  final int id;
  final String title;
  final String content;
  final String priority; // 'info', 'important', 'urgent'
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
  });

  /// Factory pour créer une instance à partir du JSON retourné par l'API Laravel
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      priority: (json['priority'] as String?) ?? 'info',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Méthode pour retransformer l'objet en JSON si nécessaire
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Helper pour vérifier si l'annonce est urgente
  bool get isUrgent => priority == 'urgent';

  /// Helper pour obtenir un libellé propre
  String get priorityLabel {
    switch (priority) {
      case 'urgent':
        return 'Urgent';
      case 'important':
        return 'Important';
      default:
        return 'Information';
    }
  }

  Map<String, String> toWidgetMap() {
    // Formatage simple DD/MM/YYYY
    final formattedDate =
        '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';

    return {'title': title, 'content': content, 'date': formattedDate};
  }
}
