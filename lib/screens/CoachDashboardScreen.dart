// lib/screens/coach_dashboard_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/announcement_model.dart';
import '../models/user_model.dart';
import '../widgets/announcements_widget.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class CoachDashboardScreen extends StatefulWidget {
  final String? userToken;

  const CoachDashboardScreen({Key? key, this.userToken}) : super(key: key);

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

int _currentIndex = 0;

class _CoachDashboardScreenState extends State<CoachDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isLoading = true;
  String? _errorMessage;

  List<AnnouncementModel> _announcements = [];
  Map<String, dynamic>? _currentSession;
  List<UserModel> _members = [];

  String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api';
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (widget.userToken != null) 'Authorization': 'Bearer ${widget.userToken}',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        http.get(Uri.parse('$baseUrl/announcements'), headers: _headers),
        http.get(Uri.parse('$baseUrl/sessions/current'), headers: _headers),
        http.get(Uri.parse('$baseUrl/users'), headers: _headers),
      ]).timeout(const Duration(seconds: 5));

      if (!mounted) return;

      setState(() {
        if (results[0].statusCode == 200) {
          final data = jsonDecode(results[0].body) as List;
          _announcements = data
              .map((j) => AnnouncementModel.fromJson(j))
              .toList();
        }
        if (results[1].statusCode == 200) {
          _currentSession = jsonDecode(results[1].body) as Map<String, dynamic>;
        }
        if (results[2].statusCode == 200) {
          final data = jsonDecode(results[2].body) as List;
          _members = data.map((j) => UserModel.fromJson(j)).toList();
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Connexion au serveur impossible.';
      });
    }
  }

  Future<void> _updateAttendance(UserModel user, String status) async {
    final oldStatus = user.status;
    setState(() => user.status = status);

    try {
      final res = await http.put(
        Uri.parse('$baseUrl/attendances/${user.id}'),
        headers: _headers,
        body: jsonEncode({
          'session_id': _currentSession?['id'],
          'status': status,
        }),
      );
      if (res.statusCode != 200) setState(() => user.status = oldStatus);
    } catch (_) {
      setState(() => user.status = oldStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Direction Technique VSM',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'Coach - Terrain PK11',
              style: TextStyle(color: Colors.amber, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.amber),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          indicatorWeight: 3,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.assignment_turned_in, size: 20),
              text: 'Appel',
            ),
            Tab(icon: Icon(Icons.sports_soccer, size: 20), text: 'Tactique'),
            Tab(icon: Icon(Icons.groups, size: 20), text: 'Effectif API'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAppelTab(),
                  const Center(child: Text('Volet Tactique')),
                  const Center(child: Text('Volet Effectif API')),
                ],
              ),
            ),

      // 🟢 TON WIDGET PERSONNALISÉ INTÉGRÉ (AVEC AUTOMATISME DE NAVIGATION)
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  // VOLET 1 : APPEL
  Widget _buildAppelTab() {
    int presents = _members.where((m) => m.status == 'present').length;
    int retards = _members.where((m) => m.status == 'late').length;
    int absents = _members.where((m) => m.status == 'absent').length;

    return ListView(
      padding: const EdgeInsets.all(12.0),
      children: [
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: _fetchDashboardData,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),

        if (_announcements.isNotEmpty)
          AnnouncementsWidget(
            announcements: _announcements.map((a) => a.toWidgetMap()).toList(),
          ),

        const SizedBox(height: 12),
        _buildSessionCard(),
        const SizedBox(height: 12),

        Row(
          children: [
            _buildStatCard(
              '$presents',
              'Présents',
              const Color(0xFFE8F5E9),
              Colors.green[800]!,
            ),
            const SizedBox(width: 8),
            _buildStatCard(
              '$retards',
              'Retards',
              const Color(0xFFFFF8E1),
              Colors.orange[800]!,
            ),
            const SizedBox(width: 8),
            _buildStatCard(
              '$absents',
              'Absents',
              const Color(0xFFFFEBEE),
              Colors.red[800]!,
            ),
          ],
        ),

        const SizedBox(height: 12),
        ..._members.map((member) => _buildPlayerTile(member)).toList(),
      ],
    );
  }

  Widget _buildSessionCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _currentSession?['type'] ?? 'SÉANCE DOMINICALE',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                _currentSession?['time'] ?? 'Dimanche, 06h30 - Stade PK11',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentSession?['team_a'] ?? 'VSM Vétérans',
                style: TextStyle(
                  color: Colors.green[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                _currentSession?['team_b'] ?? 'Entraînement Interne',
                style: TextStyle(
                  color: Colors.red[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String count,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerTile(UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF1B5E20),
            child: Text(
              '#${user.number ?? user.id}',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  user.position,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatusButton(user, 'present', 'P'),
                _buildStatusButton(user, 'late', 'R'),
                _buildStatusButton(user, 'absent', 'A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(UserModel user, String statusKey, String label) {
    bool isSelected = user.status == statusKey;

    return GestureDetector(
      onTap: () => _updateAttendance(user, statusKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8EAF6) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 14, color: Colors.purple),
              const SizedBox(width: 2),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isSelected ? Colors.purple : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
