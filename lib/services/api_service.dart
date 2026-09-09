import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/cash_balance_model.dart';
import '../models/executed_disbursements_model.dart';

class ApiService {
  // Ajuste l'URL de base selon ton environnement (10.0.2.2 pour l'émulateur Android, localhost / IP locale)
  final String baseUrl = 'http://127.0.0.1:8000/api';

  /// En-têtes HTTP standards
  Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Requête GET générique
  Future<dynamic> get(String endpoint, {String? token}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(uri, headers: _getHeaders(token));
      return _processResponse(response);
    } catch (e) {
      debugPrint('Erreur HTTP GET ($endpoint): $e');
      rethrow;
    }
  }

  /// Récupérer le solde disponible en caisse
  Future<CashBalanceModel> fetchCashBalance(String token) async {
    final response = await get('/admin/finances/cash-balance', token: token);

    // Si get() retourne un String (response.body), décoder en Map
    final Map<String, dynamic> jsonMap = response is String
        ? jsonDecode(response)
        : response;

    return CashBalanceModel.fromJson(jsonMap);
  }

  /// Récupérer les décaissements exécutés
  Future<ExecutedDisbursementsModel> fetchExecutedDisbursements(
    String token,
  ) async {
    final jsonResponse = await get(
      '/admin/finances/executed-disbursements',
      token: token,
    );
    return ExecutedDisbursementsModel.fromJson(jsonResponse);
  }

  /// Traitement centralisé des réponses HTTP
  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 401:
        throw Exception('Session expirée ou non autorisée (401).');
      case 403:
        throw Exception('Accès refusé (403).');
      case 404:
        throw Exception('Ressource non trouvée (404).');
      case 500:
        throw Exception('Erreur serveur interne (500).');
      default:
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
