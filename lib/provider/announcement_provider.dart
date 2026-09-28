import 'dart:developer';
import 'package:flutter/foundation.dart';
import '../models/announcement_model.dart';
import '../services/AnnouncementService.dart';

class AnnouncementProvider extends ChangeNotifier {
  AnnouncementService? _service;

  List<Announcement> _announcements = [];
  Announcement? _latestAnnouncement;
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  bool get hasMore => _hasMore;
  bool get isFetchingMore => _isFetchingMore;

  // Constructeur d'origine conservé (ne casse pas main.dart ni ChangeNotifierProxyProvider)
  AnnouncementProvider([this._service]);

  // --- Getters ---
  List<Announcement> get announcements => List.unmodifiable(_announcements);
  Announcement? get latestAnnouncement => _latestAnnouncement;
  bool get hasLatestAnnouncement => _latestAnnouncement != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get token => _token;

  // Permet à AuthProvider ou Main de définir le token directement
  void setToken(String? token) {
    _token = token;
    notifyListeners();
  }

  // Permet de mettre à jour le service injecté
  void updateService(AnnouncementService newService) {
    _service = newService;
    notifyListeners();
  }

  /// Récupère le dernier communiqué publié depuis le backend (/api/announcements/latest)
  Future<void> fetchLatestAnnouncement() async {
    try {
      final activeService = _service ?? AnnouncementService(token: _token);

      log('📡 Chargement du dernier communiqué...');
      final latest = await activeService.getLatestAnnouncement();

      _latestAnnouncement = latest;
      log('✅ Dernier communiqué chargé : ${latest?.title ?? "Aucun"}');
    } catch (e, stackTrace) {
      log('❌ Erreur fetchLatestAnnouncement: $e', stackTrace: stackTrace);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchNextPage() async {
    if (!_hasMore || _isFetchingMore || _isLoading) return;

    _isFetchingMore = true;
    notifyListeners();

    try {
      final activeService = _service ?? AnnouncementService(token: _token);
      final nextPage = _currentPage + 1;

      log('📡 Chargement de la page $nextPage...');
      final result = await activeService.getAnnouncements(page: nextPage);

      final List<Announcement> newItems = List<Announcement>.from(
        result['items'],
      );
      _announcements.addAll(newItems);
      _hasMore = result['hasMore'] ?? false;
      _currentPage = nextPage;

      log('✅ Page $nextPage chargée (${newItems.length} éléments ajoutés)');
    } catch (e, stackTrace) {
      log('❌ Erreur fetchNextPage: $e', stackTrace: stackTrace);
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  /// 1. Récupérer la liste des communiqués (Page 1 / Rafraîchissement)
  Future<void> fetchAnnouncements({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final activeService = _service ?? AnnouncementService(token: _token);

      log('📡 Appel fetchAnnouncements() [Page 1]...');
      // Récupération de la Map renvoyée par AnnouncementService
      final result = await activeService.getAnnouncements(page: 1);

      // Extraction de la liste et de l'indicateur de suite
      _announcements = List<Announcement>.from(result['items']);
      _hasMore = result['hasMore'] ?? false;
      _currentPage = 1;

      if (_announcements.isNotEmpty) {
        _latestAnnouncement = _announcements.first;
      }

      log(
        '✅ Communiqués chargés : ${_announcements.length} (Plus de pages : $_hasMore)',
      );
    } catch (e, stackTrace) {
      log('❌ Erreur fetchAnnouncements: $e', stackTrace: stackTrace);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 2. Ajouter un communiqué
  Future<bool> addAnnouncement({
    required String title,
    required String content,
    String category = 'general',
    String targetAudience = 'all',
    bool isUrgent = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final activeService = _service ?? AnnouncementService(token: _token);

      final newAnnouncement = await activeService.createAnnouncement({
        'title': title,
        'content': content,
        'category': category,
        'target_audience': targetAudience,
        'is_urgent': isUrgent,
      });

      _announcements.insert(0, newAnnouncement);
      _latestAnnouncement = newAnnouncement;
      return true;
    } catch (e, stackTrace) {
      log('❌ Erreur addAnnouncement: $e', stackTrace: stackTrace);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 3. Modifier un communiqué
  Future<bool> updateAnnouncement({
    required dynamic id,
    required String title,
    required String content,
    String category = 'general',
    String targetAudience = 'all',
    bool isUrgent = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final activeService = _service ?? AnnouncementService(token: _token);
      final intId = id is int ? id : int.parse(id.toString());

      final updated = await activeService.updateAnnouncement(intId, {
        'title': title,
        'content': content,
        'category': category,
        'target_audience': targetAudience,
        'is_urgent': isUrgent,
      });

      final index = _announcements.indexWhere(
        (a) => a.id.toString() == id.toString(),
      );
      if (index != -1) {
        _announcements[index] = updated;
      }

      if (_latestAnnouncement?.id.toString() == id.toString()) {
        _latestAnnouncement = updated;
      }

      return true;
    } catch (e, stackTrace) {
      log('❌ Erreur updateAnnouncement: $e', stackTrace: stackTrace);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 4. Supprimer un communiqué
  Future<bool> deleteAnnouncement(dynamic id) async {
    try {
      final activeService = _service ?? AnnouncementService(token: _token);
      final intId = id is int ? id : int.parse(id.toString());

      final success = await activeService.deleteAnnouncement(intId);

      if (success) {
        _announcements.removeWhere(
          (item) => item.id.toString() == id.toString(),
        );

        if (_latestAnnouncement?.id.toString() == id.toString()) {
          _latestAnnouncement = _announcements.isNotEmpty
              ? _announcements.first
              : null;
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      log('❌ Erreur deleteAnnouncement: $e', stackTrace: stackTrace);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
