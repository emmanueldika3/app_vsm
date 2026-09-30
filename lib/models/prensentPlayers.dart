class PresentPlayer {
  final int id;
  final String name;
  final String number;
  final String position;
  final String status;

  PresentPlayer({
    required this.id,
    required this.name,
    required this.number,
    required this.position,
    required this.status,
  });

  factory PresentPlayer.fromJson(Map<String, dynamic> json) {
    return PresentPlayer(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Inconnu',
      number: json['number']?.toString() ?? '0',
      position: json['position'] ?? 'DEF',
      status: json['status'] ?? 'present',
    );
  }
}
