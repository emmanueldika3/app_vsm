// lib/provider/event_provider.dart

import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

enum EventState { initial, loading, loaded, error }

class EventProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<EventModel> _events = [];
  EventState _state = EventState.initial;
  String _errorMessage = '';

  List<EventModel> get events => _events;
  EventState get state => _state;
  String get errorMessage => _errorMessage;

  // 📍 GETTERS PRATIQUES POUR L'UI
  bool get isLoading => _state == EventState.loading;
  bool get hasError => _state == EventState.error;

  /// Chargement des événements via ApiService.get()
  Future<void> fetchEvents({String? type}) async {
    _state = EventState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final endpoint = type != null ? '/events?type=$type' : '/events';
      final response = await _apiService.get(endpoint);

      // Traitement du retour JSON (liste directe ou objet paginé)
      final List data = response is Map ? (response['data'] ?? []) : response;
      _events = data.map((json) => EventModel.fromJson(json)).toList();

      _state = EventState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = EventState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Mise à jour de la présence à un événement via ApiService.post()
  Future<bool> updatePresence(int eventId, String status) async {
    try {
      final response = await _apiService.post('/events/$eventId/presence', {
        'status': status,
      });

      final isSuccess =
          response is Map &&
          (response['status'] == 'success' || response['success'] == true);

      if (isSuccess) {
        // Recharger les événements pour actualiser l'état dans l'UI
        await fetchEvents();
      }
      return isSuccess;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
