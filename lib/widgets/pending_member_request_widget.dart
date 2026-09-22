// lib/views/pending_requests_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/models/pending_member_request_model.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';
import 'package:vsm_app/provider/auth_provider.dart';

class PendingRequestsView extends StatelessWidget {
  const PendingRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();
    final List<PendingMemberRequest> requests = provider.pendingMemberRequests;
    final bool isLoading = provider.isLoadingPendingRequests;

    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF184332)),
          ),
        ),
      );
    }

    if (requests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text(
              "Aucune demande d'adhésion en attente.",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête avec titre et compteur dynamique
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const Text(
                "Demandes d'Adhésion en Attente",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF184332),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${provider.pendingMembersCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Liste des demandes d'adhésion
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildRequestCard(context, provider, request);
          },
        ),
      ],
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    AdminDashboardProvider provider,
    PendingMemberRequest request,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F7E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF184332).withOpacity(0.1),
            backgroundImage:
                request.avatarUrl != null && request.avatarUrl!.isNotEmpty
                ? NetworkImage(request.avatarUrl!)
                : null,
            child: (request.avatarUrl == null || request.avatarUrl!.isEmpty)
                ? Text(
                    request.fullName.trim().isNotEmpty
                        ? request.fullName
                              .trim()
                              .split(RegExp(r'\s+'))
                              .take(2)
                              .map((e) => e[0].toUpperCase())
                              .join(' ')
                        : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF184332),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.fullName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (request.positionOrPhone.isNotEmpty)
                  Text(
                    request.positionOrPhone,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                if (request.requestDate.isNotEmpty)
                  Text(
                    'Demandé le : ${request.requestDate}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 28,
                ),
                tooltip: 'Approuver',
                onPressed: () => _showRoleDialog(context, provider, request),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
                tooltip: 'Rejeter',
                onPressed: () => _confirmReject(context, provider, request),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Dialog de confirmation et choix de rôle avant validation
  void _showRoleDialog(
    BuildContext context,
    AdminDashboardProvider provider,
    PendingMemberRequest request,
  ) {
    final Map<String, String> roleMap = {
      'Joueur / Membre': 'player',
      'Trésorier': 'treasurer',
      'Coach': 'coach',
      'Secrétaire': 'secretary',
      'Administrateur': 'admin',
    };

    String selectedRoleLabel = 'Joueur / Membre';
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text('Valider ${request.fullName}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedRoleLabel,
                    decoration: const InputDecoration(
                      labelText: 'Rôle attribué',
                      border: OutlineInputBorder(),
                    ),
                    items: roleMap.keys
                        .map(
                          (label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ),
                        )
                        .toList(),
                    onChanged: isSubmitting
                        ? null
                        : (val) {
                            if (val != null) {
                              setDialogState(() => selectedRoleLabel = val);
                            }
                          },
                  ),
                  if (isSubmitting) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF184332),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF184332),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final token =
                              context.read<AuthProvider>().token ?? '';

                          if (token.isEmpty) {
                            Navigator.pop(dialogContext);
                            _showSnackBar(
                              context,
                              "Session expirée, veuillez vous reconnecter.",
                              Colors.red,
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);

                          final backendRole =
                              roleMap[selectedRoleLabel] ?? 'player';

                          final success = await provider.approveMember(
                            token: token,
                            userId: request.id,
                            role: backendRole,
                          );

                          if (context.mounted) {
                            Navigator.pop(dialogContext);
                            _showSnackBar(
                              context,
                              success
                                  ? "Demande approuvée avec succès !"
                                  : "Échec de la validation de l'adhésion.",
                              success ? Colors.green : Colors.red,
                            );
                          }
                        },
                  child: const Text(
                    'Confirmer',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Dialog de confirmation de rejet
  void _confirmReject(
    BuildContext context,
    AdminDashboardProvider provider,
    PendingMemberRequest request,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Rejeter la demande'),
          content: Text(
            'Êtes-vous sûr de vouloir rejeter l\'adhésion de ${request.fullName} ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(dialogContext);

                final token = context.read<AuthProvider>().token ?? '';
                if (token.isEmpty) {
                  _showSnackBar(
                    context,
                    "Session expirée, veuillez vous reconnecter.",
                    Colors.red,
                  );
                  return;
                }

                final success = await provider.rejectMember(
                  token: token,
                  userId: request.id,
                );

                if (context.mounted) {
                  _showSnackBar(
                    context,
                    success
                        ? "Demande d'adhésion rejetée."
                        : "Échec du rejet de la demande.",
                    success ? Colors.orange : Colors.red,
                  );
                }
              },
              child: const Text(
                'Rejeter',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
