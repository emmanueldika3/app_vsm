import 'package:flutter/material.dart';
import '../models/app_models.dart';

class MatchProvider extends ChangeNotifier {
  List<Match> _matches = [];
  bool _isLoading = false;

  List<Match> get matches => _matches;
  bool get isLoading => _isLoading;

  // Récupérer le prochain match à venir
  Match? get nextMatch {
    if (_matches.isEmpty) return null;
    return _matches.first; // Suppose que la liste est triée par date
  }

  // Charger les matchs depuis l'API
  Future<void> fetchMatches() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _matches = [
      Match(
        id: 'm1',
        opponent: 'Vétérans d\'Akonolinga',
        dateTime: DateTime.now().add(const Duration(days: 2)),
        location: 'Stade Municipal',
        attendances: {
          'user_1': AttendanceStatus.present,
          'user_2': AttendanceStatus.absent,
        },
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  // Mettre à jour la présence du joueur
  Future<void> updateAttendance({
    required String matchId,
    required String userId,
    required AttendanceStatus status,
  }) async {
    final index = _matches.indexWhere((m) => m.id == matchId);
    if (index != -1) {
      // Mise à jour locale rapide
      _matches[index].attendances[userId] = status;
      notifyListeners();

      // Envoyez l'information à votre API Laravel
      // await apiService.postAttendance(matchId, userId, status);
    }
  }
}
