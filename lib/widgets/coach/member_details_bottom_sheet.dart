import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsm_app/models/squad_member.dart';
import 'package:vsm_app/models/member_attendance_model.dart'; // Importe ton modèle

class MemberDetailsBottomSheet extends StatefulWidget {
  final SquadMember member;

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
  bool _isLoading = true;
  String? _errorMessage;
  MemberAttendanceModel? _attendanceData;

  @override
  void initState() {
    super.initState();
    _fetchMemberAttendanceHistory();
  }

  String _getBaseUrl() {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.52.90.145:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  Future<void> _fetchMemberAttendanceHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final baseUrl = _getBaseUrl();

      final response = await http.get(
        Uri.parse('$baseUrl/members/${widget.member.id}/presences-history'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Extraction de la clé "data" renvoyée par le contrôleur Laravel
        final dataMap = decoded['data'] ?? decoded;

        setState(() {
          _attendanceData = MemberAttendanceModel.fromJson(dataMap);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Erreur serveur (Code ${response.statusCode})";
          _isLoading = false;
        });
      }
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
                    "Impossible de charger l'historique.\n$_errorMessage",
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              _buildAttendanceContent(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final String memberName = widget.member.name ?? "Membre";
    final String memberPosition = widget.member.position ?? "Non défini";
    final String memberStatus = widget.member.status ?? "Actif";
    final String memberNumber = widget.member.number?.toString() ?? "-";

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: MemberDetailsBottomSheet.bordeauxRed,
          child: Text(
            memberNumber,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                memberName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MemberDetailsBottomSheet.greenDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Poste : $memberPosition • Statut : $memberStatus",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceContent() {
    if (_attendanceData == null) return const SizedBox.shrink();

    final double rate = _attendanceData!.attendanceRate;
    final int present = _attendanceData!.presentCount;
    final int absent = _attendanceData!.absentCount;
    final history = _attendanceData!.history;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatCard(
              "Taux de présence",
              "${rate.toStringAsFixed(0)}%",
              MemberDetailsBottomSheet.goldAccent,
            ),
            _buildStatCard(
              "Participations",
              "$present",
              MemberDetailsBottomSheet.greenPrimary,
            ),
            _buildStatCard("Absences", "$absent", Colors.redAccent),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          "Historique des participations aux événements",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: MemberDetailsBottomSheet.greenDark,
          ),
        ),
        const SizedBox(height: 8),
        history.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: Center(
                  child: Text(
                    "Aucun événement enregistré pour ce membre.",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final h = history[index];
                  final bool isPresent = h.status == "present";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                h.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: MemberDetailsBottomSheet.greenDark,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "Type : ${h.type} • Date : ${h.date}",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isPresent
                                ? MemberDetailsBottomSheet.greenPrimary
                                      .withOpacity(0.15)
                                : Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isPresent ? "Présent" : "Absent",
                            style: TextStyle(
                              color: isPresent
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
