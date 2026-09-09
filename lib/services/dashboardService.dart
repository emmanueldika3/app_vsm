// lib/services/dashboardService.dart

import 'dart:io';
import 'package:flutter/material.dart';

// Import du service HTTP centralisé
import 'package:vsm_app/services/api_service.dart';

// Import des modèles pour le tableau de bord utilisateur
import 'package:vsm_app/models/dashboard_data_models.dart';

class DashboardService extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // --- ÉTAT DU DASHBOARD ---
  bool _isLoading = false;
  String? _errorMessage;

  File? _profileImageFile;
  AnnouncementModel? _currentAnnouncement;
  MatchModel? _nextMatch;
  FinancialSummaryModel? _financialSummary;
  List<String> _galleryAlbums = [];
  String _playerPosition = 'Présent';

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  File? get profileImageFile => _profileImageFile;
  AnnouncementModel? get currentAnnouncement => _currentAnnouncement;
  MatchModel? get nextMatch => _nextMatch;
  FinancialSummaryModel? get financialSummary => _financialSummary;
  List<String> get galleryAlbums => List.unmodifiable(_galleryAlbums);
  String get playerPosition => _playerPosition;

  // --- MÉTHODE DYNAMIQUE DE CHARGEMENT ---
  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ApiService gère automatiquement l'URL de base et le Token Bearer
      final jsonResponse = await _apiService.get('/user/dashboard');
      final data = jsonResponse['data'] ?? jsonResponse;

      if (data['announcement'] != null) {
        _currentAnnouncement = AnnouncementModel.fromJson(
          data['announcement'] as Map<String, dynamic>,
        );
      } else {
        _currentAnnouncement = null;
      }

      if (data['next_match'] != null) {
        _nextMatch = MatchModel.fromJson(
          data['next_match'] as Map<String, dynamic>,
        );
      } else {
        _nextMatch = null;
      }

      if (data['financial'] != null) {
        _financialSummary = FinancialSummaryModel.fromJson(
          data['financial'] as Map<String, dynamic>,
        );
      } else {
        _financialSummary = null;
      }

      if (data['albums'] != null) {
        _galleryAlbums = List<String>.from(data['albums'] as List);
      } else {
        _galleryAlbums = [];
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- GESTION DE LA PHOTO DE PROFIL ---
  void updateProfileImage(File imageFile) {
    _profileImageFile = imageFile;
    notifyListeners();
  }

  void removeProfileImage() {
    _profileImageFile = null;
    notifyListeners();
  }

  // --- PRÉSENCE AU MATCH ---
  // Future<void> setPlayerPresence(int matchId, String status) async {
  //   try {
  //     _playerPosition = status;
  //     notifyListeners();

  //     // Envoi du statut de présence au backend
  //     await _apiService.post('/events/$matchId/presence', {'status': status});
  //   } catch (e) {
  //     _errorMessage = "Échec de la mise à jour de la présence : $e";
  //     notifyListeners();
  //   }
  // }
}
