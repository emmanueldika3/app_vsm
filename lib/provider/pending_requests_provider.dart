import 'package:flutter/material.dart';
import 'package:vsm_app/models/pending_member_request_model.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';
import 'package:vsm_app/services/api_service.dart';

class PendingRequestsController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<PendingMemberRequest> _pendingRequests = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PendingMemberRequest> get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final String apiToken;

  PendingRequestsController({required this.apiToken}) {
    fetchPendingRequests();
  }

  /// Récupérer les demandes d'adhésion en attente depuis l'API Laravel
  Future<void> fetchPendingRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/users/pending', token: apiToken);

      if (response != null) {
        final rawData =
            response is Map<String, dynamic> && response.containsKey('data')
            ? response['data']
            : response;

        if (rawData is List) {
          _pendingRequests = rawData
              .map((item) => PendingMemberRequest.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      _errorMessage = "Erreur lors du chargement des demandes : $e";
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approuver un membre et lui attribuer un rôle
  Future<bool> approveMember(int userId, String selectedRole) async {
    try {
      final response = await _apiService.post(
        '/users/$userId/approve',
        token: apiToken,
        body: {'role': selectedRole},
      );

      if (response != null &&
          (response['status'] == 'success' || response['success'] == true)) {
        // Retrait immédiat de la liste locale
        _pendingRequests.removeWhere((req) => req.id == userId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = "Erreur lors de l'approbation : $e";
      debugPrint(_errorMessage);
      return false;
    }
  }

  /// Rejeter une demande d'adhésion
  Future<bool> rejectMember(int userId) async {
    try {
      final response = await _apiService.post(
        '/users/$userId/reject',
        token: apiToken,
      );

      if (response != null &&
          (response['status'] == 'success' || response['success'] == true)) {
        // Retrait immédiat de la liste locale
        _pendingRequests.removeWhere((req) => req.id == userId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = "Erreur lors du rejet : $e";
      debugPrint(_errorMessage);
      return false;
    }
  }
}
