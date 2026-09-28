import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vsm_app/models/event_model.dart';

enum EventStatus { initial, loading, loaded, error }

class EventProvider with ChangeNotifier {
  EventModel? _upcomingEvent;
  EventStatus _status = EventStatus.initial;
  String _errorMessage = '';

  // Getters
  EventModel? get upcomingEvent => _upcomingEvent;
  EventStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == EventStatus.loading;
  bool get hasError => _status == EventStatus.error;
  bool get hasEvent => _upcomingEvent != null;

  final String baseUrl;

  EventProvider({this.baseUrl = 'https://api.vsmfc.com/api'});

  /// Récupère le prochain événement/match
  Future<void> fetchUpcomingEvent({String? token}) async {
    _status = EventStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/upcoming'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['data'] != null) {
          _upcomingEvent = EventModel.fromJson(data['data']);
        } else {
          _upcomingEvent = null;
        }
        _status = EventStatus.loaded;
      } else {
        _status = EventStatus.error;
        _errorMessage = 'Erreur serveur (${response.statusCode})';
      }
    } catch (e) {
      _status = EventStatus.error;
      _errorMessage = 'Impossible de contacter le serveur.';
    }

    notifyListeners();
  }

  /// Met à jour manuellement l'événement en mémoire
  void setEvent(EventModel event) {
    _upcomingEvent = event;
    _status = EventStatus.loaded;
    notifyListeners();
  }

  /// Injecte des données de test
  // void setMockEvent() {
  //   _upcomingEvent = EventModel(
  //     id: "evt_001",
  //     title: "PROCHAIN MATCH",
  //     homeTeam: "VSM FC",
  //     awayTeam: "AS Douala",
  //     venue: "Stade Bepanda",
  //     eventDateTime: DateTime.now().add(
  //       const Duration(days: 1, hours: 8, minutes: 30),
  //     ),
  //   );
  //   _status = EventStatus.loaded;
  //   notifyListeners();
  // }

  /// Réinitialise l'état
  void clear() {
    _upcomingEvent = null;
    _status = EventStatus.initial;
    _errorMessage = '';
    notifyListeners();
  }
}
