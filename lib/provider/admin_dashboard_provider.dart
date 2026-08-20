import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/admin_dashboard_model.dart';

class AdminDashboardProvider with ChangeNotifier {
  AdminDashboardData? _data;
  bool _isLoading = false;
  String? _error;

  AdminDashboardData? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final String baseUrl =
      'http://10.0.2.2:8000/api/v1'; // 10.0.2.2 pour l'émulateur Android

  // Charger les données du Dashboard
  Future<void> fetchDashboardData(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        _data = AdminDashboardData.fromJson(jsonResponse['data']);
      } else {
        _error =
            'Erreur lors du chargement des données (${response.statusCode})';
      }
    } catch (e) {
      _error = 'Impossible de contacter le serveur.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Action : Valider un membre
  Future<bool> approveMember(int memberId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/members/$memberId/approve'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await fetchDashboardData(token); // Rafraîchit les données
        return true;
      }
    } catch (_) {}
    return false;
  }
}
