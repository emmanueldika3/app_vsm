import 'dart:io';
import 'package:flutter/material.dart';
import '../models/dashboard_data_models.dart';

class DashboardService extends ChangeNotifier {
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
      // 💡 Remplacez ce bloc par vos vrais appels API / Réseau / Base de données
      // Ex: final response = await http.get(Uri.parse('https://votre-api.com/dashboard'));

      // Mise à jour avec les résultats réels
      // _currentAnnouncement = AnnouncementModel.fromJson(response.data['announcement']);
      // _nextMatch = MatchModel.fromJson(response.data['next_match']);
      // _financialSummary = FinancialSummaryModel.fromJson(response.data['financial']);
      // _galleryAlbums = List<String>.from(response.data['albums']);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage =
          "Impossible de charger les données du tableau de bord : $e";
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

  // --- PRESENCE AU MATCH ---
  void setPlayerPresence(String status) {
    _playerPosition = status;
    notifyListeners();
  }
}
