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

  // Getters
  List<EventModel> get events => _events;
  EventState get state => _state;
  String get errorMessage => _errorMessage;

  /// Charge la liste des événements
  Future<void> fetchEvents({String? type}) async {
    _state = EventState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final endpoint = type != null ? '/events?type=$type' : '/events';
      final response = await _apiService.get(endpoint);

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

  /// Met à jour la présence à un événement
  Future<bool> updatePresence(int eventId, String status) async {
    try {
      // Utilisation directe de _apiService.post
      final response = await _apiService.post('/events/$eventId/presence', {
        'status': status,
      });

      final isSuccess =
          response is Map &&
          (response['status'] == 'success' || response['success'] == true);

      if (isSuccess) {
        // Recharger les événements pour actualiser le statut dans l'UI
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
