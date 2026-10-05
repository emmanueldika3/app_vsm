import 'package:flutter/material.dart';
import 'package:vsm_app/services/TreasuryService.dart';

class MemberFinancialSummaryCard extends StatefulWidget {
  final String token; // Token Sanctum de l'utilisateur

  const MemberFinancialSummaryCard({super.key, required this.token});

  @override
  State<MemberFinancialSummaryCard> createState() =>
      _MemberFinancialSummaryCardState();
}

class _MemberFinancialSummaryCardState
    extends State<MemberFinancialSummaryCard> {
  static const Color greenPrimary = Color(0xFF1E5235);

  late final TreasuryService _treasuryService;

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _financialData;
  String _seasonName = 'Saison en cours';
  String _memberName = '';

  @override
  void initState() {
    super.initState();
    // Initialisation du service sans ID externe
    _treasuryService = TreasuryService(token: widget.token);
    _fetchMyFinancialSummary();
  }

  Future<void> _fetchMyFinancialSummary() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Appel de l'endpoint pour récupérer le résumé financier personnel
      final response = await _treasuryService.getMyFinancialSummary();

      setState(() {
        _seasonName = response['season'] ?? 'Saison en cours';
        _financialData = response['data'];
        _memberName = _financialData?['member_name'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const CircularProgressIndicator(color: greenPrimary),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            const Text(
              'Erreur de chargement',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 4),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchMyFinancialSummary,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    // Extraction sécurisée des données de l'API
    final globalStatus = _financialData?['global_status'] ?? 'Incomplet';
    final isUpToDate = globalStatus == 'En Règle';

    final adhesion = _financialData?['adhesion'] ?? {};
    final annualFee = _financialData?['annual_fee'] ?? {};

    final adhesionExpected = '${adhesion['expected'] ?? 0} FCFA';
    final adhesionPaid = adhesion['paid'] ?? 0;
    final adhesionPaidFormatted = '$adhesionPaid FCFA';
    final adhesionStatus = adhesion['status'] ?? 'Impayé';

    final annualExpected = '${annualFee['expected'] ?? 0} FCFA';
    final annualPaidAmount = annualFee['paid'] ?? 0;
    final annualPaidFormatted = '$annualPaidAmount FCFA';
    final annualRemaining = '${annualFee['remaining'] ?? 0} FCFA';
    final annualStatus = annualFee['status'] ?? 'Partiel / Dû';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-titre de la carte avec la saison dynamique et le nom du membre
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "État Financier Global",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: greenPrimary,
                      ),
                    ),
                    if (_memberName.isNotEmpty)
                      Text(
                        _memberName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    Text(
                      _seasonName,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isUpToDate ? Colors.green : Colors.orange)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  globalStatus,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isUpToDate ? Colors.green : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Droit d'Adhésion (Dynamique)
          _buildSectionHeader("1. Droit d'Adhésion (Exercice Actif)"),
          const SizedBox(height: 8),
          _buildClickableStatusRow(
            context,
            title: "Montant Adhésion",
            amount: adhesionExpected,
            status: adhesionStatus,
            statusColor: adhesionPaid >= (adhesion['expected'] ?? 0)
                ? Colors.green
                : Colors.red,
            detailsTitle: "Détails de l'Adhésion",
            detailsContent:
                "Montant attendu : $adhesionExpected\nMontant versé : $adhesionPaidFormatted\nStatut : $adhesionStatus",
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 2. Cotisation Annuelle (Dynamique)
          _buildSectionHeader("2. Cotisation Annuelle"),
          const SizedBox(height: 8),
          _buildClickableStatusRow(
            context,
            title: "Attendu Annuel",
            amount: annualExpected,
            status: "$annualPaidFormatted Versés",
            statusColor: greenPrimary,
            detailsTitle: "Détails de la Cotisation Annuelle",
            detailsContent:
                "Objectif annuel : $annualExpected\nTotal déjà versé : $annualPaidFormatted",
          ),
          const SizedBox(height: 6),
          _buildClickableStatusRow(
            context,
            title: "Reste à Payer",
            amount: annualRemaining,
            status: annualStatus,
            statusColor: (annualFee['remaining'] ?? 0) == 0
                ? Colors.green
                : Colors.orange.shade800,
            detailsTitle: "État du Solde Annuel",
            detailsContent:
                "Reste dû pour clôturer l'exercice : $annualRemaining\nÉtat : $annualStatus",
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 3. Section Événements / Autre (Gardée interactive)
          _buildSectionHeader("3. Participations & Événements"),
          const SizedBox(height: 8),
          _buildClickableStatusRow(
            context,
            title: "Cotisations Spéciales",
            amount: "À jour",
            status: "Validé",
            statusColor: Colors.blue.shade700,
            detailsTitle: "Détails des Événements",
            detailsContent:
                "Consultez le détail de vos participations aux matchs et caisses spéciales de la saison.",
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildClickableStatusRow(
    BuildContext context, {
    required String title,
    required String amount,
    required String status,
    required Color statusColor,
    required String detailsTitle,
    required String detailsContent,
  }) {
    return InkWell(
      onTap: () {
        _showDetailsModal(context, detailsTitle, detailsContent);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ),
            Row(
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsModal(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: greenPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Fermer"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
