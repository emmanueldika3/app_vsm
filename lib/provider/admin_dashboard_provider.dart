import 'package:flutter/material.dart';
import '../models/admin_dashboard_model.dart';
import '../models/cash_balance_model.dart';
import '../models/executed_disbursements_model.dart';
import '../models/pending_disbursements_model.dart';
import '../models/collected_contributions_model.dart';

import '../services/api_service.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // --- Données globales du Dashboard ---
  AdminDashboardData? _dashboardData;
  bool _isLoadingData = false;

  AdminDashboardData? get dashboardData => _dashboardData;
  bool get isLoadingData => _isLoadingData;

  // --- Cash Balance (Solde disponible) ---
  CashBalanceModel? _cashBalance;
  bool _isLoadingCashBalance = false;

  CashBalanceModel? get cashBalance => _cashBalance;
  bool get isLoadingCashBalance => _isLoadingCashBalance;

  // --- Executed Disbursements (Décaissements exécutés) ---
  ExecutedDisbursementsModel? _executedDisbursements;
  bool _isLoadingExecutedDisbursements = false;

  ExecutedDisbursementsModel? get executedDisbursements =>
      _executedDisbursements;
  bool get isLoadingExecutedDisbursements => _isLoadingExecutedDisbursements;

  CollectedContributionsModel? _collectedContributions;
  bool _isLoadingCollectedContributions = false;

  CollectedContributionsModel? get collectedContributions =>
      _collectedContributions;
  bool get isLoadingCollectedContributions => _isLoadingCollectedContributions;

  // --- Pending Disbursements (Décaissements en attente) ---
  PendingDisbursementsModel? _pendingDisbursements;
  bool _isLoadingPendingDisbursements = false;

  PendingDisbursementsModel? get pendingDisbursements => _pendingDisbursements;
  bool get isLoadingPendingDisbursements => _isLoadingPendingDisbursements;

  // --- Getter global de chargement ---
  bool get isLoading =>
      _isLoadingData ||
      _isLoadingCashBalance ||
      _isLoadingExecutedDisbursements ||
      _isLoadingPendingDisbursements ||
      _isLoadingCollectedContributions;

  /// Charger l'ensemble des métriques du dashboard en une seule fois
  Future<void> fetchDashboardData(String token) async {
    _isLoadingData = true;
    _isLoadingCashBalance = true;
    _isLoadingExecutedDisbursements = true;
    _isLoadingPendingDisbursements = true;
    _isLoadingCollectedContributions = true;
    notifyListeners();

    try {
      // Exécution parallèle sécurisée des requêtes
      final results = await Future.wait<dynamic>([
        _apiService.get('/admin/dashboard', token: token).catchError((e) {
          debugPrint("Erreur Dashboard General: $e");
          return null;
        }),
        _apiService.fetchCashBalance(token).catchError((e) {
          debugPrint("Erreur CashBalance: $e");
          return CashBalanceModel(totalBalance: 0.0);
        }),
        _apiService.fetchExecutedDisbursements(token).catchError((e) {
          debugPrint("Erreur ExecutedDisbursements: $e");
          return ExecutedDisbursementsModel(
            totalExecuted: 0.0,
            executedCount: 0,
          );
        }),
        _apiService.fetchPendingDisbursements(token).catchError((e) {
          debugPrint("Erreur PendingDisbursements: $e");
          return PendingDisbursementsModel(totalPending: 0.0, pendingCount: 0);
        }),
        _apiService.fetchCollectedContributions(token).catchError((e) {
          debugPrint("Erreur CollectedContributions: $e");
          return CollectedContributionsModel(
            totalCollected: 0.0,
            contributionsCount: 0,
          );
        }),
      ]);

      // Attribution sécurisée des données
      if (results[0] != null) {
        _dashboardData = AdminDashboardData.fromJson(results[0]);
      }
      if (results[1] is CashBalanceModel) {
        _cashBalance = results[1] as CashBalanceModel;
      }
      if (results[2] is ExecutedDisbursementsModel) {
        _executedDisbursements = results[2] as ExecutedDisbursementsModel;
      }
      if (results[3] is PendingDisbursementsModel) {
        _pendingDisbursements = results[3] as PendingDisbursementsModel;
      }
      if (results[4] is CollectedContributionsModel)
        _collectedContributions = results[4] as CollectedContributionsModel;
    } catch (e) {
      debugPrint("Erreur globale Dashboard: $e");
    } finally {
      _isLoadingData = false;
      _isLoadingCashBalance = false;
      _isLoadingExecutedDisbursements = false;
      _isLoadingPendingDisbursements = false;
      _isLoadingCollectedContributions = false;
      notifyListeners();
    }
  }

  /// Charger uniquement le solde disponible
  Future<void> loadCashBalance(String token) async {
    _isLoadingCashBalance = true;
    notifyListeners();

    try {
      _cashBalance = await _apiService.fetchCashBalance(token);
    } catch (e) {
      debugPrint("Erreur CashBalance: $e");
    } finally {
      _isLoadingCashBalance = false;
      notifyListeners();
    }
  }

  /// Charger uniquement les décaissements exécutés
  Future<void> loadExecutedDisbursements(String token) async {
    _isLoadingExecutedDisbursements = true;
    notifyListeners();

    try {
      _executedDisbursements = await _apiService.fetchExecutedDisbursements(
        token,
      );
    } catch (e) {
      debugPrint("Erreur ExecutedDisbursements: $e");
    } finally {
      _isLoadingExecutedDisbursements = false;
      notifyListeners();
    }
  }

  /// Charger uniquement les décaissements en attente
  Future<void> loadPendingDisbursements(String token) async {
    _isLoadingPendingDisbursements = true;
    notifyListeners();

    try {
      _pendingDisbursements = await _apiService.fetchPendingDisbursements(
        token,
      );
    } catch (e) {
      debugPrint("Erreur PendingDisbursements: $e");
    } finally {
      _isLoadingPendingDisbursements = false;
      notifyListeners();
    }
  }

  /// Charger uniquement les cotisations perçues
  Future<void> loadCollectedContributions(String token) async {
    _isLoadingCollectedContributions = true;
    notifyListeners();

    try {
      _collectedContributions = await _apiService.fetchCollectedContributions(
        token,
      );
    } catch (e) {
      debugPrint("Erreur CollectedContributions: $e");
    } finally {
      _isLoadingCollectedContributions = false;
      notifyListeners();
    }
  }
}
