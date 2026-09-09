import 'package:flutter/material.dart';
import '../models/admin_dashboard_model.dart';
import '../models/cash_balance_model.dart';
import '../models/executed_disbursements_model.dart';
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

  // --- Getter global de chargement ---
  bool get isLoading =>
      _isLoadingData ||
      _isLoadingCashBalance ||
      _isLoadingExecutedDisbursements;

  /// Charger l'ensemble des métriques du dashboard en une seule fois
  Future<void> fetchDashboardData(String token) async {
    _isLoadingData = true;
    _isLoadingCashBalance = true;
    _isLoadingExecutedDisbursements = true;
    notifyListeners();

    try {
      // Exécution parallèle des requêtes pour une réponse rapide de l'UI
      final results = await Future.wait([
        _apiService.get('/admin/dashboard', token: token),
        _apiService.fetchCashBalance(token),
        _apiService.fetchExecutedDisbursements(token),
      ]);

      if (results[0] != null) {
        _dashboardData = AdminDashboardData.fromJson(results[0]);
      }
      _cashBalance = results[1] as CashBalanceModel?;
      _executedDisbursements = results[2] as ExecutedDisbursementsModel?;
    } catch (e) {
      debugPrint("Erreur globale Dashboard: $e");
    } finally {
      _isLoadingData = false;
      _isLoadingCashBalance = false;
      _isLoadingExecutedDisbursements = false;
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
}
