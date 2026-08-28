// lib/provider/announcement_provider.dart

import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../services/api_service.dart';

enum AnnouncementState { initial, loading, loaded, error }

class AnnouncementProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<AnnouncementModel> _announcements = [];
  AnnouncementState _state = AnnouncementState.initial;
  String _errorMessage = '';

  // Getters
  List<AnnouncementModel> get announcements => _announcements;
  AnnouncementState get state => _state;
  String get errorMessage => _errorMessage;

  bool get isLoading => _state == AnnouncementState.loading;
  bool get hasError => _state == AnnouncementState.error;

  /// Charge la liste des annonces depuis l'API Laravel
  Future<void> fetchAnnouncements() async {
    _state = AnnouncementState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _announcements = await _apiService.fetchAnnouncements();
      _state = AnnouncementState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = AnnouncementState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Publie une nouvelle annonce (Admin / Coach)
  Future<bool> createAnnouncement({
    required String title,
    required String content,
    String priority = 'info',
  }) async {
    try {
      final success = await _apiService.createAnnouncement(
        title: title,
        content: content,
        priority: priority,
      );

      if (success) {
        // Recharger la liste pour inclure la nouvelle annonce
        await fetchAnnouncements();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
