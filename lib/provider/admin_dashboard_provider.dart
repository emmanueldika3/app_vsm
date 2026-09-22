import 'package:flutter/material.dart';
import '../models/admin_dashboard_model.dart';
import '../models/cash_balance_model.dart';
import '../models/executed_disbursements_model.dart';
import '../models/pending_disbursements_model.dart';
import '../models/collected_contributions_model.dart';
import '../models/pending_member_request_model.dart';
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

  // --- Executed Disbursements ---
  ExecutedDisbursementsModel? _executedDisbursements;
  bool _isLoadingExecutedDisbursements = false;

  ExecutedDisbursementsModel? get executedDisbursements =>
      _executedDisbursements;
  bool get isLoadingExecutedDisbursements => _isLoadingExecutedDisbursements;

  // --- Collected Contributions ---
  CollectedContributionsModel? _collectedContributions;
  bool _isLoadingCollectedContributions = false;

  CollectedContributionsModel? get collectedContributions =>
      _collectedContributions;
  bool get isLoadingCollectedContributions => _isLoadingCollectedContributions;

  // --- Pending Disbursements ---
  PendingDisbursementsModel? _pendingDisbursements;
  bool _isLoadingPendingDisbursements = false;

  PendingDisbursementsModel? get pendingDisbursements => _pendingDisbursements;
  bool get isLoadingPendingDisbursements => _isLoadingPendingDisbursements;

  // --- Lists & Tables ---
  List<dynamic> _pendingExpensesList = [];
  bool _isLoadingPendingExpensesList = false;

  List<dynamic> get pendingExpensesList => _pendingExpensesList;
  bool get isLoadingPendingExpensesList => _isLoadingPendingExpensesList;

  List<dynamic> _pendingDisbursementsList = [];
  bool _isLoadingPending = false;

  List<dynamic> get pendingDisbursementsList => _pendingDisbursementsList;
  bool get isLoadingPending => _isLoadingPending;

  List<PendingMemberRequest> _pendingMemberRequests = [];
  bool _isLoadingPendingMembers = false;

  List<PendingMemberRequest> get pendingMemberRequests =>
      _pendingMemberRequests;
  bool get isLoadingPendingMembers => _isLoadingPendingMembers;

  bool get isLoadingPendingRequests => _isLoadingPendingMembers;

  // Getter sécurisé pour les membres en attente
  int get pendingMembersCount {
    if (_pendingMemberRequests.isNotEmpty) {
      return _pendingMemberRequests.length;
    }

    final membersDyn = _dashboardData?.membersOverview as dynamic;
    if (membersDyn != null) {
      try {
        return membersDyn.pendingRequests ?? membersDyn.newThisMonth ?? 0;
      } catch (_) {
        return 0;
      }
    }

    return 0;
  }

  // --- GESTION DES MEMBRES ACTIFS & ANNUAIRE ---
  List<dynamic> _activeMembers = [];
  bool _isLoadingActiveMembers = false;

  List<dynamic> get activeMembers => _activeMembers;
  bool get isLoadingActiveMembers => _isLoadingActiveMembers;

  // Getter sécurisé pour activeMembersCount (Compte uniquement les membres dont status == 'active')
  int get activeMembersCount {
    if (_activeMembers.isNotEmpty) {
      return _activeMembers.where((m) => m['status'] == 'active').length;
    }

    final membersDyn = _dashboardData?.membersOverview as dynamic;
    if (membersDyn != null) {
      try {
        return (membersDyn.activeMembers as num?)?.toInt() ?? 0;
      } catch (_) {
        return 0;
      }
    }

    return 0;
  }

  // --- Getter global de chargement ---
  bool get isLoading =>
      _isLoadingData ||
      _isLoadingCashBalance ||
      _isLoadingExecutedDisbursements ||
      _isLoadingPendingDisbursements ||
      _isLoadingCollectedContributions ||
      _isLoadingPendingExpensesList ||
      _isLoadingPending ||
      _isLoadingPendingMembers ||
      _isLoadingActiveMembers;

  Future<void> fetchDashboardData(String token) async {
    _isLoadingData = true;
    _isLoadingCashBalance = true;
    _isLoadingExecutedDisbursements = true;
    _isLoadingPendingDisbursements = true;
    _isLoadingCollectedContributions = true;
    _isLoadingPendingExpensesList = true;
    _isLoadingPendingMembers = true;
    _isLoadingActiveMembers = true;
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
        // Endpoint /users filtré par statut pending
        _apiService.get('/users?status=pending', token: token).catchError((e) {
          debugPrint("Erreur Membres en attente: $e");
          return null;
        }),
        // Endpoint /users pour tous les membres enregistrés
        _apiService.get('/users', token: token).catchError((e) {
          debugPrint("Erreur Membres actifs: $e");
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
      if (results[6] != null) {
        final rawData =
            results[6] is Map<String, dynamic> && results[6].containsKey('data')
            ? results[6]['data']
            : results[6];
        if (rawData is List) {
          _pendingMemberRequests = rawData
              .map((item) => PendingMemberRequest.fromJson(item))
              .toList();
        }
      }
      if (results[7] != null) {
        final rawData =
            results[7] is Map<String, dynamic> && results[7].containsKey('data')
            ? results[7]['data']
            : results[7];
        if (rawData is List) {
          _activeMembers = rawData
              .where((m) => m['status'] != 'pending')
              .toList();
        }
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
      _isLoadingPendingMembers = false;
      _isLoadingActiveMembers = false;
      notifyListeners();
    }
  }

  Future<void> fetchActiveMembers(String token) async {
    _isLoadingActiveMembers = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/users', token: token);

      if (response != null) {
        final rawData =
            response is Map<String, dynamic> && response.containsKey('data')
            ? response['data']
            : response;

        if (rawData is List) {
          _activeMembers = rawData
              .where((m) => m['status'] != 'pending')
              .toList();
        } else {
          _activeMembers = [];
        }
      } else {
        _activeMembers = [];
      }
    } catch (e) {
      _activeMembers = [];
      debugPrint('Erreur lors de la récupération des membres: $e');
    } finally {
      _isLoadingActiveMembers = false;
      notifyListeners();
    }
  }

  Future<void> fetchPendingMembers(String token) async {
    _isLoadingPendingMembers = true;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '/users?status=pending',
        token: token,
      );

      if (response != null) {
        final rawData =
            response is Map<String, dynamic> && response.containsKey('data')
            ? response['data']
            : response;

        if (rawData is List) {
          _pendingMemberRequests = rawData
              .map((item) => PendingMemberRequest.fromJson(item))
              .toList();
        } else {
          _pendingMemberRequests = [];
        }
      } else {
        _pendingMemberRequests = [];
      }
    } catch (e) {
      _pendingMemberRequests = [];
      debugPrint('Erreur lors de la récupération des membres en attente: $e');
    } finally {
      _isLoadingPendingMembers = false;
      notifyListeners();
    }
  }

  Future<void> fetchPendingMemberRequests(String token) async {
    return fetchPendingMembers(token);
  }

  Future<bool> approveMember({
    required String token,
    required int userId,
    required String role,
  }) async {
    try {
      final response = await _apiService.post(
        '/users/$userId/approve',
        token: token,
        body: {'role': role},
      );

      if (response != null &&
          (response['status'] == 'success' || response['success'] == true)) {
        _pendingMemberRequests.removeWhere((req) => req.id == userId);

        await Future.wait([
          fetchDashboardData(token),
          fetchActiveMembers(token),
        ]);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Erreur approveMember: $e");
      return false;
    }
  }

  Future<bool> rejectMember({
    required String token,
    required int userId,
  }) async {
    try {
      final response = await _apiService.post(
        '/users/$userId/reject',
        token: token,
      );

      if (response != null &&
          (response['status'] == 'success' || response['success'] == true)) {
        _pendingMemberRequests.removeWhere((req) => req.id == userId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Erreur rejectMember: $e");
      return false;
    }
  }

  /// Attribution dynamique du rôle d'un membre
  Future<bool> updateMemberRole({
    required String token,
    required int userId,
    required String newRole,
  }) async {
    try {
      final response = await _apiService.updateUserRole(token, userId, newRole);

      if (response != null &&
          (response['status'] == 'success' || response['success'] == true)) {
        final index = _activeMembers.indexWhere((m) => m['id'] == userId);
        if (index != -1) {
          _activeMembers[index]['role'] = newRole;
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Erreur updateMemberRole: $e");
      return false;
    }
  }

  /// Activation / Suspension de l'accès d'un membre
  Future<bool> toggleMemberStatus({
    required String token,
    required int userId,
    required bool activate,
  }) async {
    try {
      final response = activate
          ? await _apiService.activateUser(token, userId)
          : await _apiService.suspendUser(token, userId);

      if (response != null &&
          (response['status'] == 'success' || response['success'] == true)) {
        // 1. Mise à jour instantanée du statut local pour décrémenter/incrémenter le getter tout de suite
        final index = _activeMembers.indexWhere((m) => m['id'] == userId);
        if (index != -1) {
          _activeMembers[index]['status'] = activate ? 'active' : 'suspended';
        }

        // 2. Synchronisation complète des membres depuis le serveur
        await fetchActiveMembers(token);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Erreur toggleMemberStatus: $e");
      return false;
    }
  }

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

  Future<void> fetchPendingDisbursementsList(String token) async {
    return fetchPendingDisbursements(token);
  }

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
      _pendingExpensesList = [];
      debugPrint("Erreur fetchPendingExpensesList: $e");
    } finally {
      _isLoadingPendingExpensesList = false;
      notifyListeners();
    }
  }

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
        _pendingExpensesList.removeWhere((item) => item['id'] == expenseId);
        _pendingDisbursementsList.removeWhere(
          (item) => item['id'] == expenseId,
        );

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
