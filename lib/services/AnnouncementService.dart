import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/announcement_model.dart';

class AnnouncementService {
  final String baseUrl;
  final String? token; // Token Sanctum

  /// Constructeur avec détection dynamique de l'environnement de test
  AnnouncementService({String? baseUrl, this.token})
    : baseUrl = baseUrl ?? _getDefaultBaseUrl();

  /// Méthode privée pour déterminer l'URL de base selon la plateforme
  static String _getDefaultBaseUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.52.90.145:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  // En-têtes HTTP centralisés
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  /// Helper interne pour construire des URLs propres sans doublons de slashes
  Uri _buildUri(String path) {
    final cleanUrl = '$baseUrl/$path'.replaceAll(RegExp(r'(?<!:)/+'), '/');
    return Uri.parse(cleanUrl);
  }

  /// 1. Récupérer le dernier communiqué publié (/api/announcements/latest)
  Future<Announcement?> getLatestAnnouncement() async {
    try {
      final response = await http.get(
        _buildUri('announcements/latest'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);

        // L'API Laravel renvoie { "status": "success", "data": { ... } }
        if (body['data'] != null) {
          return Announcement.fromJson(body['data']);
        }
        return null;
      } else {
        log('❌ Erreur getLatestAnnouncement status: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      log('❌ Erreur getLatestAnnouncement: $e', stackTrace: stackTrace);
      return null;
    }
  }

  /// 2. Récupérer la liste des communiqués (avec support de la pagination Laravel)
  Future<Map<String, dynamic>> getAnnouncements({int page = 1}) async {
    final response = await http.get(
      _buildUri('announcements?page=$page'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      // Si Laravel renvoie du 'paginate()', les éléments sont dans 'data'
      final List<dynamic> rawList = decoded is Map<String, dynamic>
          ? (decoded['data'] ?? [])
          : (decoded as List<dynamic>);

      final items = rawList.map((j) => Announcement.fromJson(j)).toList();
      final bool hasMore =
          decoded is Map<String, dynamic> && decoded['next_page_url'] != null;

      return {'items': items, 'hasMore': hasMore};
    } else {
      _handleError(response);
      throw Exception('Impossible de charger les communiqués.');
    }
  }

  /// 3. Récupérer un communiqué par son ID (méthode show)
  Future<Announcement> getAnnouncement(int id) async {
    final response = await http.get(
      _buildUri('announcements/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      final Map<String, dynamic> data =
          decoded is Map<String, dynamic> && decoded.containsKey('data')
          ? decoded['data']
          : (decoded as Map<String, dynamic>);

      return Announcement.fromJson(data);
    } else {
      _handleError(response);
      throw Exception('Impossible de charger le communiqué.');
    }
  }

  /// 4. Créer un nouveau communiqué (Accepte Map OU arguments nommés)
  Future<Announcement> createAnnouncement(
    dynamic dataOrTitle, {
    String? content,
    String category = 'general',
    String targetAudience = 'all',
    bool isUrgent = false,
  }) async {
    final Map<String, dynamic> body = dataOrTitle is Map<String, dynamic>
        ? dataOrTitle
        : {
            'title': dataOrTitle.toString(),
            'content': content ?? '',
            'category': category,
            'target_audience': targetAudience,
            'is_urgent': isUrgent,
          };

    final response = await http.post(
      _buildUri('announcements'),
      headers: _headers,
      body: json.encode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Announcement.fromJson(json.decode(response.body));
    } else {
      _handleError(response);
      throw Exception('Échec de la création du communiqué.');
    }
  }

  /// 5. Mettre à jour un communiqué existant (Accepte Map OU arguments nommés)
  Future<Announcement> updateAnnouncement(
    int id,
    dynamic dataOrTitle, {
    String? content,
    String? category,
    String? targetAudience,
    bool? isUrgent,
  }) async {
    final Map<String, dynamic> body = dataOrTitle is Map<String, dynamic>
        ? dataOrTitle
        : {
            if (dataOrTitle != null) 'title': dataOrTitle.toString(),
            if (content != null) 'content': content,
            if (category != null) 'category': category,
            if (targetAudience != null) 'target_audience': targetAudience,
            if (isUrgent != null) 'is_urgent': isUrgent,
          };

    final response = await http.put(
      _buildUri('announcements/$id'),
      headers: _headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return Announcement.fromJson(json.decode(response.body));
    } else {
      _handleError(response);
      throw Exception('Échec de la mise à jour du communiqué.');
    }
  }

  /// 6. Supprimer un communiqué
  Future<bool> deleteAnnouncement(int id) async {
    final response = await http.delete(
      _buildUri('announcements/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      _handleError(response);
      return false;
    }
  }

  /// Gestionnaire d'erreurs d'API
  void _handleError(http.Response response) {
    switch (response.statusCode) {
      case 401:
        throw Exception('Non authentifié. Veuillez vous reconnecter.');
      case 403:
        final body = json.decode(response.body);
        throw Exception(body['message'] ?? 'Accès refusé. Réservé au bureau.');
      case 404:
        throw Exception('Communiqué introuvable.');
      case 422:
        final body = json.decode(response.body);
        throw Exception('Données invalides : ${body['errors']}');
      default:
        throw Exception('Erreur serveur (${response.statusCode}).');
    }
  }
}
