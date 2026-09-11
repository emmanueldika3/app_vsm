import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/cash_balance_model.dart';
import '../models/executed_disbursements_model.dart';
import '../models/pending_disbursements_model.dart';
import '../models/collected_contributions_model.dart';

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

    final Map<String, dynamic> jsonMap = response is String
        ? jsonDecode(response) as Map<String, dynamic>
        : (response is http.Response
              ? jsonDecode(response.body) as Map<String, dynamic>
              : response as Map<String, dynamic>);

    return CashBalanceModel.fromJson(jsonMap);
  }

  /// Récupérer les décaissements exécutés
  Future<ExecutedDisbursementsModel> fetchExecutedDisbursements(
    String token,
  ) async {
    final response = await get(
      '/admin/finances/executed-disbursements',
      token: token,
    );

    // Sécurisation du décodage du JSON
    final Map<String, dynamic> jsonMap = response is String
        ? jsonDecode(response) as Map<String, dynamic>
        : (response is http.Response
              ? jsonDecode(response.body) as Map<String, dynamic>
              : response as Map<String, dynamic>);

    return ExecutedDisbursementsModel.fromJson(jsonMap);
  }

  /// Traitement centralisé des réponses HTTP
  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) return {};
        return jsonDecode(response.body);
      case 400:
        throw Exception('Requête invalide (400).');
      case 401:
        throw Exception('Session expirée ou non autorisée (401).');
      case 403:
        throw Exception('Accès refusé (403).');
      case 404:
        throw Exception('Ressource non trouvée (404).');
      case 422:
        throw Exception('Données non valides (422): ${response.body}');
      case 500:
        throw Exception('Erreur serveur interne (500).');
      default:
        throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
    }
  }

  Future<PendingDisbursementsModel> fetchPendingDisbursements(
    String token,
  ) async {
    final response = await get(
      '/admin/finances/pending-disbursements',
      token: token,
    );

    Map<String, dynamic> jsonMap;

    if (response is String) {
      jsonMap = jsonDecode(response) as Map<String, dynamic>;
    } else if (response is Map<String, dynamic>) {
      jsonMap = response;
    } else {
      // Si ton helper 'get' renvoie un objet Response de http (http.Response)
      jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    }

    return PendingDisbursementsModel.fromJson(jsonMap);
  }

  //Récupérer les contributions validées
  Future<CollectedContributionsModel> fetchCollectedContributions(
    String token,
  ) async {
    final response = await get(
      '/admin/finances/collected-contributions',
      token: token,
    );

    final Map<String, dynamic> jsonMap = response is String
        ? jsonDecode(response) as Map<String, dynamic>
        : (response is http.Response
              ? jsonDecode(response.body) as Map<String, dynamic>
              : response as Map<String, dynamic>);

    return CollectedContributionsModel.fromJson(jsonMap);
  }

  // décaissement ordonné par le président
  Future<bool> processExpenseOrdonnancement({
    required String token,
    required int expenseId,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final Uri url = Uri.parse('$baseUrl/decaissements/$expenseId/ordonner');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status,
          if (rejectionReason != null) 'rejection_reason': rejectionReason,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Erreur HTTP Ordonnancement: $e");
      return false;
    }
  }
}
