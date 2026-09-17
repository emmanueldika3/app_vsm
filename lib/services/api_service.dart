import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/cash_balance_model.dart';
import '../models/executed_disbursements_model.dart';
import '../models/pending_disbursements_model.dart';
import '../models/collected_contributions_model.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  // Génération centralisée des en-têtes HTTP
  Map<String, String> _getHeaders(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Méthode GET générique avec retour JSON décodé
  Future<dynamic> get(String endpoint, {String? token}) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$baseUrl$cleanEndpoint');

    try {
      final response = await http.get(url, headers: _getHeaders(token));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }

      throw Exception(
        'Erreur GET ($endpoint): ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      debugPrint('Exception GET ($endpoint): $e');
      rethrow;
    }
  }

  /// Méthode POST générique
  Future<dynamic> post(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$baseUrl$cleanEndpoint');

    try {
      final response = await http.post(
        url,
        headers: _getHeaders(token),
        body: body != null ? jsonEncode(body) : null,
      );

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Exception POST ($endpoint): $e');
      rethrow;
    }
  }

  /// Récupération du solde en caisse
  Future<CashBalanceModel> fetchCashBalance(String token) async {
    final response = await this.get(
      '/admin/finances/cash-balance',
      token: token,
    );
    return CashBalanceModel.fromJson(response);
  }

  /// Récupération des décaissements exécutés
  Future<ExecutedDisbursementsModel> fetchExecutedDisbursements(
    String token,
  ) async {
    final response = await this.get(
      '/admin/finances/executed-disbursements',
      token: token,
    );
    return ExecutedDisbursementsModel.fromJson(response);
  }

  /// Récupération du compteur des décaissements en attente
  Future<PendingDisbursementsModel> fetchPendingDisbursements(
    String token,
  ) async {
    final response = await this.get(
      '/admin/finances/pending-disbursements',
      token: token,
    );
    return PendingDisbursementsModel.fromJson(response);
  }

  /// Récupération des cotisations perçues
  Future<CollectedContributionsModel> fetchCollectedContributions(
    String token,
  ) async {
    final response = await this.get(
      '/admin/finances/collected-contributions',
      token: token,
    );
    return CollectedContributionsModel.fromJson(response);
  }
}
