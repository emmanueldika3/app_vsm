import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:vsm_app/models/contribution_model.dart';

class TreasuryService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }

    if (Platform.isAndroid) {
      return 'http://10.52.90.145:8000/api';
    }

    return 'http://127.0.0.1:8000/api';
  }

  final String token;

  TreasuryService({required this.token});

  // 1. Obtenir le statut des cotisations du membre connecté
  Future<Map<String, dynamic>> getMyStatus() async {
    final response = await http.get(
      Uri.parse('$baseUrl/contributions/my-status'),
      headers: _headers(),
    );

    return _handleResponse(response);
  }

  // Récupérer le résumé financier du membre connecté (via le token)
  Future<Map<String, dynamic>> getMyFinancialSummary() async {
    final response = await http.get(
      Uri.parse('$baseUrl/contributions/my-financial-summary'),
      headers: _headers(), // Inclut le header Authorization: Bearer <token>
    );

    return _handleResponse(response);
  }

  // 3. Liste globale des cotisations (Trésorier/Admin) mappée avec ContributionModel
  Future<List<ContributionModel>> getContributions({
    String? month,
    int? userId,
  }) async {
    final queryParams = <String, String>{};
    if (month != null) queryParams['month'] = month;
    if (userId != null) queryParams['user_id'] = userId.toString();

    final uri = Uri.parse(
      '$baseUrl/contributions',
    ).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers());

    final decoded = _handleResponse(response);

    // Extraction de la liste depuis la structure de la réponse Laravel
    final List records = decoded['data']['records'] ?? [];
    return records.map((json) => ContributionModel.fromJson(json)).toList();
  }

  // 4. Enregistrer un paiement de cotisation
  Future<ContributionModel> storeContribution({
    required int userId,
    required double amount,
    required String
    paymentType, // 'monthly_fee', 'annual_fee', 'adhesion', etc.
    required String paymentMethod, // 'cash', 'orange_money', 'mtn_momo'
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/contributions'),
      headers: _headers(),
      body: jsonEncode({
        'user_id': userId,
        'amount': amount,
        'payment_type': paymentType,
        'payment_method': paymentMethod,
        if (notes != null) 'notes': notes,
      }),
    );

    final decoded = _handleResponse(response);
    return ContributionModel.fromJson(decoded['data']);
  }

  // 5. État des impayés et des membres
  Future<Map<String, dynamic>> getMembersStatus(int userId) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/contributions/member-financial-summary/$userId',
      ), // ⚠️ Pas de :1 ou de caractères bizarres ici
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        "Erreur 404 : Impossible de trouver le résumé financier pour ce membre.",
      );
    }
  }

  // 6. Indicateurs financiers et taux de recouvrement
  Future<Map<String, dynamic>> getMetrics({String period = 'month'}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/contributions/metrics?period=$period'),
      headers: _headers(),
    );

    return _handleResponse(response);
  }

  // Helpers internes
  Map<String, String> _headers() => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Une erreur est survenue.');
    }
  }
}
