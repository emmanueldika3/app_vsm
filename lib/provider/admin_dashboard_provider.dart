import 'package:flutter/material.dart';
import '../models/admin_dashboard_model.dart';
import '../models/cash_balance_model.dart';
import '../models/executed_disbursements_model.dart';
import '../models/pending_disbursements_model.dart';
import '../models/collected_contributions_model.dart';
import '../models/expense_model.dart';
import '../services/api_service.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // --- Gestion des erreurs ---
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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

  // --- Collected Contributions (Cotisations perçues) ---
  CollectedContributionsModel? _collectedContributions;
  bool _isLoadingCollectedContributions = false;

  CollectedContributionsModel? get collectedContributions =>
      _collectedContributions;
  bool get isLoadingCollectedContributions => _isLoadingCollectedContributions;

  // --- Pending Disbursements (Métriques / Compteur) ---
  PendingDisbursementsModel? _pendingDisbursements;
  bool _isLoadingPendingDisbursements = false;

  PendingDisbursementsModel? get pendingDisbursements => _pendingDisbursements;
  bool get isLoadingPendingDisbursements => _isLoadingPendingDisbursements;

  // --- Liste des dépenses pour le Centre d'Ordonnancement ---
  List<dynamic> _pendingExpensesList = [];
  bool _isLoadingPendingExpensesList = false;

  List<dynamic> get pendingExpensesList => _pendingExpensesList;
  bool get isLoadingPendingExpensesList => _isLoadingPendingExpensesList;

  // --- Liste dédiée aux décaissements en attente ---
  List<dynamic> _pendingDisbursementsList = [];
  bool _isLoadingPending = false;

  List<dynamic> get pendingDisbursementsList => _pendingDisbursementsList;
  bool get isLoadingPending => _isLoadingPending;

  // --- Getter global de chargement ---
  bool get isLoading =>
      _isLoadingData ||
      _isLoadingCashBalance ||
      _isLoadingExecutedDisbursements ||
      _isLoadingPendingDisbursements ||
      _isLoadingCollectedContributions ||
      _isLoadingPendingExpensesList ||
      _isLoadingPending;

  /// Charger l'ensemble des métriques du dashboard
  Future<void> fetchDashboardData(String token) async {
    _isLoadingData = true;
    _isLoadingCashBalance = true;
    _isLoadingExecutedDisbursements = true;
    _isLoadingPendingDisbursements = true;
    _isLoadingCollectedContributions = true;
    _isLoadingPendingExpensesList = true;
    notifyListeners();

    try {
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
        _apiService.get('/decaissements', token: token).catchError((e) {
          debugPrint("Erreur Liste Decaissements: $e");
          return null;
        }),
      ]);

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
      if (results[4] is CollectedContributionsModel) {
        _collectedContributions = results[4] as CollectedContributionsModel;
      }
      if (results[5] != null && results[5]['data'] != null) {
        final List<dynamic> list = results[5]['data'];
        _pendingExpensesList = list
            .where((e) => e['status'] == 'pending')
            .toList();
      }
    } catch (e) {
      debugPrint("Erreur globale Dashboard: $e");
    } finally {
      _isLoadingData = false;
      _isLoadingCashBalance = false;
      _isLoadingExecutedDisbursements = false;
      _isLoadingPendingDisbursements = false;
      _isLoadingCollectedContributions = false;
      _isLoadingPendingExpensesList = false;
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

  /// Charger la métrique des décaissements en attente (modèle statistique)
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

  /// Appelé par le widget d'ordonnancement pour charger la liste des décaissements à valider
  Future<void> fetchPendingDisbursements(String token) async {
    _isLoadingPending = true;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/admin/decaissements/pending',
        token: token,
      );

      if (response is Map<String, dynamic> && response.containsKey('data')) {
        _pendingDisbursementsList = List<dynamic>.from(response['data']);
      } else if (response is List) {
        _pendingDisbursementsList = List<dynamic>.from(response);
      } else {
        _pendingDisbursementsList = [];
      }
    } catch (e) {
      _errorMessage = e.toString();
      _pendingDisbursementsList = [];
      debugPrint("Erreur fetchPendingDisbursements: $e");
    } finally {
      _isLoadingPending = false;
      notifyListeners();
    }
  }

  /// Alias de compatibilité
  Future<void> fetchPendingDisbursementsList(String token) async {
    return fetchPendingDisbursements(token);
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

  /// Charger la liste des demandes à ordonner (depuis /decaissements)
  Future<void> fetchPendingExpensesList(String token) async {
    _isLoadingPendingExpensesList = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/decaissements', token: token);
      if (response != null && response['data'] != null) {
        final List<dynamic> list = response['data'];
        _pendingExpensesList = list
            .where((e) => e['status'] == 'pending')
            .toList();
      } else {
        _pendingExpensesList = [];
      }
    } catch (e) {
      debugPrint("Erreur fetchPendingExpensesList: $e");
    } finally {
      _isLoadingPendingExpensesList = false;
      notifyListeners();
    }
  }

  /// Traitement d'ordonnancement (Validation / Rejet)
  Future<bool> processExpenseOrdonnancement({
    required String token,
    required int expenseId,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'status': status,
        if (rejectionReason != null && rejectionReason.isNotEmpty)
          'rejection_reason': rejectionReason,
      };

      final response = await _apiService.post(
        '/admin/decaissements/$expenseId/ordonner',
        token: token,
        body: payload,
      );

      if (response != null &&
          (response['status'] == 'success' || response['success'] == true)) {
        // Retrait synchrone des éléments dans les 2 listes
        _pendingExpensesList.removeWhere((item) => item['id'] == expenseId);
        _pendingDisbursementsList.removeWhere(
          (item) => item['id'] == expenseId,
        );

        // Rafraîchissement des compteurs
        loadPendingDisbursements(token);
        loadCashBalance(token);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Erreur lors de l'ordonnancement: $e");
      return false;
    }
  }

  /// Alias de méthode pour ordonnerDecaissement
  Future<bool> ordonnerDecaissement({
    required String token,
    required int expenseId,
    required String status,
    String? rejectionReason,
  }) async {
    return processExpenseOrdonnancement(
      token: token,
      expenseId: expenseId,
      status: status,
      rejectionReason: rejectionReason,
    );
  }
}
