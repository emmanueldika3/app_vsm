// lib/provider/auth_provider.dart

import 'dart:convert';
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://127.0.0.1:8000/api';
    }
  }

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  UserModel? get currentUser => _user; // Alias pour compatibilité
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _user != null;

  // --- GETTERS DE HÉRARCHIE ET PERMISSIONS ---

  /// Super Utilisateurs / Administration Système & Club
  bool get isAdmin =>
      _user?.role == UserRole.admin || _user?.role == UserRole.president;

  /// Droits d'Encadrement / Composition / Feuilles de Match
  bool get isCoach =>
      _user?.role == UserRole.coach ||
      _user?.role == UserRole.president ||
      _user?.role == UserRole.admin;

  /// Droits de Gestion Financière / Cotisations
  bool get isTreasurer =>
      _user?.role == UserRole.treasurer ||
      _user?.role == UserRole.president ||
      _user?.role == UserRole.admin;

  /// Méthodes de contrôle explicite pour les vues
  bool get canManageUsers => isAdmin;
  bool get canManageMatches => isCoach;
  bool get canManageFinances => isTreasurer;

  AuthProvider() {
    tryAutoLogin();
  }

  // --- EN-TÊTES HTTP PAR DÉFAUT ---
  Map<String, String> _getHeaders({bool withAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // 🔑 CONNEXION
  Future<bool> login({required String phone, required String password}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _getHeaders(withAuth: false),
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _token = responseData['token'] ?? responseData['access_token'];

        final userJson = responseData['user'] ?? responseData['data'];
        if (userJson != null) {
          _user = UserModel.fromJson(userJson);
        }

        final prefs = await SharedPreferences.getInstance();
        if (_token != null) await prefs.setString(_tokenKey, _token!);
        if (_user != null) {
          await prefs.setString(_userKey, jsonEncode(_user!.toJson()));
        }

        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = responseData['message'] ?? 'Identifiants incorrects.';
        _setLoading(false);
        return false;
      }
    } catch (error) {
      _errorMessage = 'Erreur de connexion réseau. Vérifiez le serveur.';
      _setLoading(false);
      return false;
    }
  }

  // 🔄 RAFRAÎCHISSEMENT DU PROFIL DEPUIS L'API
  Future<void> fetchProfile() async {
    if (_token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userJson = data['data'] ?? data['user'] ?? data;
        _user = UserModel.fromJson(userJson);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(_user!.toJson()));

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement du profil: $e');
    }
  }

  // 📸 MISE À JOUR DE LA PHOTO DE PROFIL
  Future<bool> updateProfilePhoto(File imageFile) async {
    if (_token == null) return false;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/user/photo'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath('photo', imageFile.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['user'] != null) {
          _user = UserModel.fromJson(responseData['user']);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userKey, jsonEncode(_user!.toJson()));
        }

        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'envoi de la photo : $e');
    }
    return false;
  }

  // 🔄 AUTO-CONNEXION
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(_tokenKey) || !prefs.containsKey(_userKey)) {
      return false;
    }

    try {
      _token = prefs.getString(_tokenKey);
      final userMap = jsonDecode(prefs.getString(_userKey)!);
      _user = UserModel.fromJson(userMap);

      notifyListeners();
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  // 🚪 DÉCONNEXION
  Future<void> logout() async {
    if (_token != null) {
      try {
        await http.post(Uri.parse('$baseUrl/logout'), headers: _getHeaders());
      } catch (_) {}
    }

    _user = null;
    _token = null;
    _errorMessage = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);

    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
