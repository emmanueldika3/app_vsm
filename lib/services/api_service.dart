import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/cash_balance_model.dart';
import '../models/executed_disbursements_model.dart';
import '../models/pending_disbursements_model.dart';
import '../models/collected_contributions_model.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    if (Platform.isAndroid) {
      return 'http://10.208.55.145:8000/api';
    }

    return 'http://127.0.0.1:8000/api';
  }

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

  /// Méthode PUT générique
  Future<dynamic> put(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$baseUrl$cleanEndpoint');

    try {
      final response = await http.put(
        url,
        headers: _getHeaders(token),
        body: body != null ? jsonEncode(body) : null,
      );

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Exception PUT ($endpoint): $e');
      rethrow;
    }
  }

  /// Méthode DELETE générique
  Future<dynamic> delete(String endpoint, {String? token}) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = Uri.parse('$baseUrl$cleanEndpoint');

    try {
      final response = await http.delete(url, headers: _getHeaders(token));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return {'status': 'success'};
        return jsonDecode(response.body);
      }

      throw Exception(
        'Erreur DELETE ($endpoint): ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      debugPrint('Exception DELETE ($endpoint): $e');
      rethrow;
    }
  }

  // ==========================================
  // GESTION DES MEMBRES ET ROLES
  // ==========================================

  Future<dynamic> updateUserRole(String token, int userId, String role) async {
    return await put('/users/$userId/role', token: token, body: {'role': role});
  }

  Future<dynamic> suspendUser(String token, int userId) async {
    return await post('/users/$userId/suspend', token: token);
  }

  Future<dynamic> activateUser(String token, int userId) async {
    return await post('/users/$userId/activate', token: token);
  }

  // ==========================================
  // FINANCES ET DASHBOARD
  // ==========================================

  Future<CashBalanceModel> fetchCashBalance(String token) async {
    final response = await this.get(
      '/admin/finances/cash-balance',
      token: token,
    );
    return CashBalanceModel.fromJson(response);
  }

  Future<ExecutedDisbursementsModel> fetchExecutedDisbursements(
    String token,
  ) async {
    final response = await this.get(
      '/admin/finances/executed-disbursements',
      token: token,
    );
    return ExecutedDisbursementsModel.fromJson(response);
  }

  Future<PendingDisbursementsModel> fetchPendingDisbursements(
    String token,
  ) async {
    final response = await this.get(
      '/admin/finances/pending-disbursements',
      token: token,
    );
    return PendingDisbursementsModel.fromJson(response);
  }

  Future<CollectedContributionsModel> fetchCollectedContributions(
    String token,
  ) async {
    final response = await this.get(
      '/admin/finances/collected-contributions',
      token: token,
    );
    return CollectedContributionsModel.fromJson(response);
  }

  // ==========================================
  // GESTION DES CONTRIBUTIONS (TRÉSORERIE)
  // ==========================================

  /// Récupérer la liste globale des contributions
  Future<dynamic> fetchContributions(String token) async {
    return await get('/contributions', token: token);
  }

  /// Enregistrer une nouvelle contribution
  Future<dynamic> addContribution(
    String token, {
    required int userId,
    required double amount,
    String type = 'standard',
    String status = 'paid',
    String? paidAt,
  }) async {
    return await post(
      '/contributions',
      token: token,
      body: {
        'user_id': userId,
        'amount': amount,
        'type': type,
        'status': status,
        'paid_at': paidAt ?? DateTime.now().toString().substring(0, 19),
      },
    );
  }

  /// Mettre à jour une contribution existante
  Future<dynamic> updateContribution(
    String token, {
    required int id,
    int? userId,
    double? amount,
    String? type,
    String? status,
    String? paidAt,
  }) async {
    final Map<String, dynamic> body = {};
    if (userId != null) body['user_id'] = userId;
    if (amount != null) body['amount'] = amount;
    if (type != null) body['type'] = type;
    if (status != null) body['status'] = status;
    if (paidAt != null) body['paid_at'] = paidAt;

    return await put('/contributions/$id', token: token, body: body);
  }

  /// Supprimer une contribution
  Future<dynamic> removeContribution(String token, int id) async {
    return await delete('/contributions/$id', token: token);
  }
}
