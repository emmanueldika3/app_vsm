import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vsm_app/models/event_model.dart';
import 'package:vsm_app/models/prensentPlayers.dart';

enum EventStatus { initial, loading, loaded, error }

class EventProvider with ChangeNotifier {
  EventModel? _upcomingEvent;
  EventStatus _status = EventStatus.initial;
  String _errorMessage = '';

  // --- Champs pour le statut tactique et le joueur connecté ---
  String _myStatus = "Non identifié";
  PresentPlayer? _connectedPlayer;

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

  // Getters exposés
  String get myStatus => _myStatus;
  PresentPlayer? get connectedPlayer => _connectedPlayer;

  /// Helper pour nettoyer les URLs et éviter les redirections 301 (POST -> GET)
  Uri _buildUri(String path) {
    final rawUrl = '$baseUrl/$path';
    final cleanUrl = rawUrl.replaceAll(RegExp(r'(?<!:)/+'), '/');
    return Uri.parse(cleanUrl);
  }

  /// Récupère le prochain événement/match depuis le backend[cite: 2]
  Future<void> fetchUpcomingEvent({String? token}) async {
    _status = EventStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http
          .get(
            _buildUri('events/upcoming'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
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

        // --- Récupération du statut et du joueur connecté renvoyés par Laravel[cite: 2] ---
        _myStatus = data['my_status'] ?? "Non identifié";

        if (data['connected_player'] != null) {
          _connectedPlayer = PresentPlayer.fromJson(data['connected_player']);
        } else {
          _connectedPlayer = null;
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

  /// Met à jour la présence (compatible route publique avec `userId` ou protégée avec `token`)[cite: 2]
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

    // 1. Mise à jour des compteurs
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

    // 2. Mise à jour optimiste de l'UI
    _upcomingEvent = _upcomingEvent!.copyWith(
      userPresence: newStatus,
      presentCount: present,
      uncertainCount: uncertain,
      absentCount: absent,
    );
    notifyListeners();

    // 3. Envoi de la requête POST
    try {
      final response = await http
          .post(
            _buildUri('events/${_upcomingEvent!.id}/presence'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
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
        debugPrint('Erreur serveur (${response.statusCode}):${response.body}');
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

  /// --- CRÉER UN ÉVÉNEMENT ---
  Future<bool> createEvent(
    Map<String, dynamic> eventData, {
    String? token,
  }) async {
    try {
      final response = await http
          .post(
            _buildUri('events'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: json.encode(eventData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchUpcomingEvent(token: token);
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

  /// --- METTRE À JOUR UN ÉVÉNEMENT ---
  Future<bool> updateEvent(
    int eventId,
    Map<String, dynamic> eventData, {
    String? token,
  }) async {
    try {
      final response = await http
          .put(
            _buildUri('events/$eventId'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: json.encode(eventData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        await fetchUpcomingEvent(token: token);
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

  /// --- SUPPRIMER / ANNULER UN ÉVÉNEMENT ---
  Future<bool> deleteEvent(int eventId, {String? token}) async {
    try {
      final response = await http
          .delete(
            _buildUri('events/$eventId'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (_upcomingEvent?.id == eventId) {
          _upcomingEvent = null;
          notifyListeners();
        }
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
    _myStatus = "Non identifié";
    _connectedPlayer = null;
    notifyListeners();
  }
}
