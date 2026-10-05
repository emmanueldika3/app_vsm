import 'package:flutter/material.dart';
import 'package:vsm_app/models/squad_member.dart';
import 'package:vsm_app/services/TreasuryService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberDetailsBottomSheet extends StatefulWidget {
  final SquadMember member; // On passe directement le membre cliqué

  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color greenDark = Color(0xFF0A1E13);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color bordeauxRed = Color(0xFF6B1D2F);

  const MemberDetailsBottomSheet({Key? key, required this.member})
    : super(key: key);

  @override
  State<MemberDetailsBottomSheet> createState() =>
      _MemberDetailsBottomSheetState();
}

class _MemberDetailsBottomSheetState extends State<MemberDetailsBottomSheet> {
  TreasuryService? _treasuryService;

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _memberDetailsData;

  @override
  void initState() {
    super.initState();
    _initServiceAndFetch();
  }

  Future<void> _initServiceAndFetch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      _treasuryService = TreasuryService(token: token);
      await _fetchMemberDetails();
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur d'initialisation : $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMemberDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Appel de l'API avec l'ID du membre cliqué
      final response = await _treasuryService!.getMembersStatus(
        widget.member.id,
      );

      setState(() {
        _memberDetailsData = response['data'] ?? response;
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // En-tête avec les infos directes du membre (fallback si l'API tarde ou échoue)
            _buildHeader(),
            const Divider(height: 24),

            if (_isLoading)
              const SizedBox(
                height: 150,
                child: Center(
                  child: CircularProgressIndicator(
                    color: MemberDetailsBottomSheet.greenPrimary,
                  ),
                ),
              )
            else if (_errorMessage != null)
              SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    "Impossible de charger les détails financiers.\n$_errorMessage",
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              _buildFinancialContent(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: MemberDetailsBottomSheet.bordeauxRed,
          child: Text(
            widget.member.number.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.member.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MemberDetailsBottomSheet.greenDark,
              ),
            ),
            Text(
              "Poste : ${widget.member.position} • Statut : ${widget.member.status}",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialContent() {
    final attendanceRate = (_memberDetailsData?['attendance_rate'] ?? 0.0)
        .toDouble();
    final presentCount = _memberDetailsData?['present_count'] ?? 0;
    final absentCount = _memberDetailsData?['absent_count'] ?? 0;
    final List historyList = _memberDetailsData?['history'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cartes de statistiques dynamiques
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard(
              "Présence",
              "${attendanceRate.toStringAsFixed(0)}%",
              MemberDetailsBottomSheet.goldAccent,
            ),
            _buildStatCard(
              "Présents",
              "$presentCount",
              MemberDetailsBottomSheet.greenPrimary,
            ),
            _buildStatCard("Absents", "$absentCount", Colors.redAccent),
          ],
        ),
        const SizedBox(height: 20),

        const Text(
          "Historique des participations",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: MemberDetailsBottomSheet.greenDark,
          ),
        ),
        const SizedBox(height: 8),

        historyList.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: Center(
                  child: Text(
                    "Aucun historique enregistré pour ce membre.",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: historyList.length,
                itemBuilder: (context, index) {
                  final h = historyList[index];
                  final title = h['title'] ?? h['opponent'] ?? 'Événement';
                  final date = h['date'] ?? '';
                  final status = h['status'] ?? 'Inconnu';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              date,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: status == "present"
                                ? MemberDetailsBottomSheet.greenPrimary
                                      .withOpacity(0.15)
                                : Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: status == "present"
                                  ? MemberDetailsBottomSheet.greenPrimary
                                  : Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
