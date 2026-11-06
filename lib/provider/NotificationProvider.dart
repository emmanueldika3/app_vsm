// lib/provider/notification_provider.dart
import 'package:flutter/foundation.dart';

class NotificationProvider extends ChangeNotifier {
  // Compteurs de notifications par index d'onglet (0: Vue d'ensemble, 1: Tactique, etc.)
  final Map<int, int> _tabNotifications = {
    0: 0,
    1: 0, // Exemple: 2 nouveaux éléments en Tactique
    2: 0,
    3: 0,
    4: 0, // Exemple: 1 nouveau communiqué
  };

  // Suivi de l'onglet actif qui vient d'être cliqué (pour appliquer la surbrillance)
  int? _highlightedTab;

  Map<int, int> get tabNotifications => _tabNotifications;
  int? get highlightedTab => _highlightedTab;

  // Méthode pour marquer un onglet comme lu (remet le compteur à 0 et active la surbrillance)
  void markTabAsRead(int tabIndex) {
    if ((_tabNotifications[tabIndex] ?? 0) > 0) {
      _tabNotifications[tabIndex] = 0;
      _highlightedTab = tabIndex;
      notifyListeners();

      // Retire la surbrillance après 4 secondes
      Future.delayed(const Duration(seconds: 4), () {
        if (_highlightedTab == tabIndex) {
          _highlightedTab = null;
          notifyListeners();
        }
      });
    }
  }

  // Méthode pour ajouter une notification (appelée par le backend / websockets / services)
  void addNotification(int tabIndex, {int count = 1}) {
    _tabNotifications[tabIndex] = (_tabNotifications[tabIndex] ?? 0) + count;
    notifyListeners();
  }
}
