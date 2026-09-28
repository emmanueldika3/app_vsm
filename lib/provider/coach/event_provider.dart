import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vsm_app/models/event_model.dart';

enum EventStatus { initial, loading, loaded, error }

class EventProvider with ChangeNotifier {
  EventModel? _upcomingEvent;
  EventStatus _status = EventStatus.initial;
  String _errorMessage = '';

  /// Gestion dynamique de l'URL de base selon la plateforme
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    if (Platform.isAndroid) {
      return 'http://10.52.90.145:8000/api';
    }

    return 'http://127.0.0.1:8000/api';
  }

  // Getters
  EventModel? get upcomingEvent => _upcomingEvent;
  EventStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == EventStatus.loading;
  bool get hasError => _status == EventStatus.error;
  bool get hasEvent => _upcomingEvent != null;

  /// Récupère le prochain événement/match depuis le backend[cite: 3]
  Future<void> fetchUpcomingEvent({String? token}) async {
    _status = EventStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/events/upcoming'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

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
        _errorMessage =
            'Erreur lors du chargement de l\'événement (${response.statusCode})';
      }
    } on SocketException {
      _status = EventStatus.error;
      _errorMessage = 'Connexion Internet ou serveur indisponible.';
    } on FormatException {
      _status = EventStatus.error;
      _errorMessage = 'Format de réponse invalide du serveur.';
    } catch (e) {
      _status = EventStatus.error;
      _errorMessage = 'Une erreur inattendue est survenue : $e';
    }

    notifyListeners();
  }

  /// Créer un nouvel événement en base de données
  Future<bool> createEvent(
    Map<String, dynamic> eventData, {
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(eventData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchUpcomingEvent(token: token);
        return true;
      } else {
        _errorMessage = 'Erreur lors de la création (${response.statusCode})';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur réseau : $e';
      notifyListeners();
      return false;
    }
  }

  /// Modifier un événement existant en base de données
  Future<bool> updateEvent(
    dynamic eventId,
    Map<String, dynamic> eventData, {
    String? token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(eventData),
      );

      if (response.statusCode == 200) {
        await fetchUpcomingEvent(token: token);
        return true;
      } else {
        _errorMessage =
            'Erreur lors de la modification (${response.statusCode})';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur réseau : $e';
      notifyListeners();
      return false;
    }
  }

  /// Annuler / Supprimer un événement en base de données
  Future<bool> cancelEvent(dynamic eventId, {String? token}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _upcomingEvent = null;
        _status = EventStatus.loaded;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Erreur lors de l\'annulation (${response.statusCode})';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur réseau : $e';
      notifyListeners();
      return false;
    }
  }

  /// Mettre à jour la présence de l'utilisateur connecté
  Future<void> updatePresence(String statusKey, {String? token}) async {
    if (_upcomingEvent == null) return;

    // Optimistic update local
    // (Ajustez selon la structure de votre modèle EventModel)
    notifyListeners();

    try {
      await http.post(
        Uri.parse('$baseUrl/events/${_upcomingEvent!.id}/presence'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': statusKey}),
      );
    } catch (e) {
      debugPrint('Erreur mise à jour présence : $e');
    }
  }

  /// Définit directement un objet EventModel en mémoire
  void setEvent(EventModel event) {
    _upcomingEvent = event;
    _status = EventStatus.loaded;
    _errorMessage = '';
    notifyListeners();
  }

  /// Réinitialise l'état du provider
  void clearEvent() {
    _upcomingEvent = null;
    _status = EventStatus.initial;
    _errorMessage = '';
    notifyListeners();
  }
}
