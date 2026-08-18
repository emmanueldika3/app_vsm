import 'package:flutter/foundation.dart';
import 'dart:io';

// ==========================================
// 1. MODÈLES DE DONNÉES DYNAMIQUES
// ==========================================

/// Modèle pour les communiqués officiels diffusés par le Bureau/Secrétariat
class BureauAnnouncement {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final bool isUrgent;

  BureauAnnouncement({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.isUrgent = false,
  });

  factory BureauAnnouncement.fromJson(Map<String, dynamic> json) {
    return BureauAnnouncement(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Communiqué',
      content: json['content'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      isUrgent: json['isUrgent'] ?? false,
    );
  }
}

/// Modèle pour les convocations aux matchs transmises par le Staff / Coach
class MatchConvocation {
  final String matchId;
  final String opponent;
  final String location;
  final DateTime matchDate;
  final String callTime;
  final String status; // Ex: 'Confirmé', 'En attente', 'Annulé'

  MatchConvocation({
    required this.matchId,
    required this.opponent,
    required this.location,
    required this.matchDate,
    required this.callTime,
    this.status = 'En attente',
  });

  factory MatchConvocation.fromJson(Map<String, dynamic> json) {
    return MatchConvocation(
      matchId: json['matchId'] ?? '',
      opponent: json['opponent'] ?? 'Adversaire',
      location: json['location'] ?? 'Stade de PK11',
      matchDate: json['matchDate'] != null
          ? DateTime.parse(json['matchDate'])
          : DateTime.now(),
      callTime: json['callTime'] ?? '06H30',
      status: json['status'] ?? 'En attente',
    );
  }
}

/// Modèle pour le suivi financier d'un joueur transmis par la Trésorerie
class PlayerFinancialSummary {
  final double monthlyFeeAmount;
  final bool isMonthlyPaid;
  final double solidarityFeeAmount;
  final bool isSolidarityPaid;
  final String currentMonth;

  PlayerFinancialSummary({
    required this.monthlyFeeAmount,
    required this.isMonthlyPaid,
    required this.solidarityFeeAmount,
    required this.isSolidarityPaid,
    required this.currentMonth,
  });

  factory PlayerFinancialSummary.fromJson(Map<String, dynamic> json) {
    return PlayerFinancialSummary(
      monthlyFeeAmount: (json['monthlyFeeAmount'] ?? 0).toDouble(),
      isMonthlyPaid: json['isMonthlyPaid'] ?? false,
      solidarityFeeAmount: (json['solidarityFeeAmount'] ?? 0).toDouble(),
      isSolidarityPaid: json['isSolidarityPaid'] ?? false,
      currentMonth: json['currentMonth'] ?? '',
    );
  }
}

// ==========================================
// 2. PROVIDER (GESTIONNAIRE D'ÉTAT)
// ==========================================

class PlayerDashboardProvider extends ChangeNotifier {
  // --- États Privés ---
  BureauAnnouncement? _latestAnnouncement;
  MatchConvocation? _nextMatch;
  PlayerFinancialSummary? _financialSummary;
  List<String> _galleryImageUrls = [];
  bool _isLoading = false;
  String? _errorMessage;

  // --- Getters Publics ---
  BureauAnnouncement? get latestAnnouncement => _latestAnnouncement;
  MatchConvocation? get nextMatch => _nextMatch;
  PlayerFinancialSummary? get financialSummary => _financialSummary;
  List<String> get galleryImageUrls => _galleryImageUrls;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- MÉTHODES DE MISE À JOUR DE L'ÉTAT (INJECTION DE DONNÉES) ---

  /// Met à jour le communiqué officiel (Secrétariat / Bureau)
  void updateAnnouncement(BureauAnnouncement? announcement) {
    _latestAnnouncement = announcement;
    notifyListeners();
  }

  /// Met à jour la convocation du match à venir (Coach / Staff)
  void updateConvocation(MatchConvocation? convocation) {
    _nextMatch = convocation;
    notifyListeners();
  }

  /// Met à jour l'état des cotisations du joueur (Trésorerie)
  void updateFinancials(PlayerFinancialSummary? financials) {
    _financialSummary = financials;
    notifyListeners();
  }

  /// Réalise une mise à jour globale des médias/photos de la Galerie
  void updateGallery(List<String> urls) {
    _galleryImageUrls = List.from(urls);
    notifyListeners();
  }

  File? _profileImageFile;

  File? get profileImageFile => _profileImageFile;

  /// Met à jour la photo de profil du joueur
  void updateProfileImage(File imageFile) {
    _profileImageFile = imageFile;
    notifyListeners(); // Rafraîchit l'avatar dans l'interface Joueur
  }

  /// Ajoute une photo à la galerie existante
  void addGalleryPhoto(String photoUrl) {
    _galleryImageUrls.insert(0, photoUrl);
    notifyListeners();
  }

  /// Contrôle le spinner de chargement (par exemple pendant les requêtes HTTP/Firebase)
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Définit une erreur
  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Réinitialise toutes les données (à appeler lors de la déconnexion par exemple)
  void resetState() {
    _latestAnnouncement = null;
    _nextMatch = null;
    _financialSummary = null;
    _galleryImageUrls.clear();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
