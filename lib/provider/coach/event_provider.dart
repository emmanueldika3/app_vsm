import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

  /// Helper pour récupérer automatiquement le token stocké localement si non fourni
  Future<String?> _getToken(String? providedToken) async {
    if (providedToken != null && providedToken.isNotEmpty) {
      return providedToken;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token') ??
          prefs.getString('token') ??
          prefs.getString('access_token');
    } catch (e) {
      debugPrint('Erreur lors de la récupération du token local : $e');
      return null;
    }
  }

  /// Helper pour construire l'URI proprement
  Uri _buildUri(String path) {
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$cleanBase/$cleanPath');
  }

  /// Récupère le prochain événement/match depuis le backend
  Future<void> fetchUpcomingEvent({String? token}) async {
    _status = EventStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final activeToken = await _getToken(token);

      final response = await http
          .get(
            _buildUri('events/upcoming'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (activeToken != null && activeToken.isNotEmpty)
                'Authorization': 'Bearer $activeToken',
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

  /// Créer un nouvel événement (Coach / Admin)
  Future<bool> createEvent(
    Map<String, dynamic> eventData, {
    String? token,
  }) async {
    final activeToken = await _getToken(token);
    try {
      final response = await http.post(
        _buildUri('events'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (activeToken != null && activeToken.isNotEmpty)
            'Authorization': 'Bearer $activeToken',
        },
        body: json.encode(eventData),
      );

      if (response.statusCode == 201) {
        await fetchUpcomingEvent(token: activeToken);
        return true;
      } else {
        debugPrint(
          'Erreur création événement (${response.statusCode}): ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Exception createEvent: $e');
      return false;
    }
  }

  /// Mettre à jour un événement existant (Coach / Admin)
  Future<bool> updateEvent(
    int eventId,
    Map<String, dynamic> eventData, {
    String? token,
  }) async {
    final activeToken = await _getToken(token);
    try {
      final response = await http.put(
        _buildUri('events/$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (activeToken != null && activeToken.isNotEmpty)
            'Authorization': 'Bearer $activeToken',
        },
        body: json.encode(eventData),
      );

      if (response.statusCode == 200) {
        await fetchUpcomingEvent(token: activeToken);
        return true;
      } else {
        debugPrint(
          'Erreur modification événement (${response.statusCode}): ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Exception updateEvent: $e');
      return false;
    }
  }

  /// Supprimer un événement (Coach / Admin)
  Future<bool> deleteEvent(int eventId, {String? token}) async {
    final activeToken = await _getToken(token);
    try {
      final response = await http.delete(
        _buildUri('events/$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (activeToken != null && activeToken.isNotEmpty)
            'Authorization': 'Bearer $activeToken',
        },
      );

      if (response.statusCode == 200) {
        _upcomingEvent = null;
        notifyListeners();
        return true;
      } else {
        debugPrint(
          'Erreur suppression événement (${response.statusCode}): ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Exception deleteEvent: $e');
      return false;
    }
  }

  /// Met à jour la présence personnelle
  Future<bool> updatePresence(
    String newStatus, {
    int? userId,
    String? token,
  }) async {
    if (_upcomingEvent == null) return false;

    final oldStatus = _upcomingEvent!.userPresence ?? 'none';
    if (oldStatus == newStatus) return true;

    int present = _upcomingEvent!.presentCount;
    int uncertain = _upcomingEvent!.uncertainCount;
    int absent = _upcomingEvent!.absentCount;

    // 1. Mise à jour locale des compteurs (Mise à jour optimiste)
    switch (oldStatus) {
      case 'present':
        if (present > 0) present--;
        break;
      case 'uncertain':
        if (uncertain > 0) uncertain--;
        break;
      case 'absent':
        if (absent > 0) absent--;
        break;
    }

    switch (newStatus) {
      case 'present':
        present++;
        break;
      case 'uncertain':
        uncertain++;
        break;
      case 'absent':
        absent++;
        break;
    }

    final previousEvent = _upcomingEvent;

    _upcomingEvent = _upcomingEvent!.copyWith(
      userPresence: newStatus,
      presentCount: present,
      uncertainCount: uncertain,
      absentCount: absent,
    );
    notifyListeners();

    // 2. Récupération sécurisée du token
    final activeToken = await _getToken(token);

    // 3. Envoi de la requête POST vers l'API Laravel
    try {
      final response = await http
          .post(
            _buildUri('events/${_upcomingEvent!.id}/presence'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (activeToken != null && activeToken.isNotEmpty)
                'Authorization': 'Bearer $activeToken',
            },
            body: json.encode({
              'status': newStatus,
              if (userId != null) 'user_id': userId,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['data'] != null) {
          _upcomingEvent = EventModel.fromJson(data['data']);
          notifyListeners();
        }
        return true;
      } else {
        debugPrint('Erreur serveur (${response.statusCode}): ${response.body}');
        _upcomingEvent = previousEvent;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Exception updatePresence: $e');
      _upcomingEvent = previousEvent;
      notifyListeners();
      return false;
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
