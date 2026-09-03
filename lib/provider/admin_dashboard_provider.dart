// lib/providers/admin_dashboard_provider.dart

import 'package:flutter/material.dart';
import '../models/admin_dashboard_model.dart'; // Contient tout ce qu'il faut !
import '../services/api_service.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  AdminDashboardData? _dashboardData;
  bool _isLoading = false;

  AdminDashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/admin/dashboard');
      _dashboardData = AdminDashboardData.fromJson(response);
    } catch (e) {
      debugPrint("Erreur Dashboard: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
