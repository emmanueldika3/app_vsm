import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsm_app/models/event_model.dart';
import 'package:vsm_app/widgets/coach/overview_tab_widget.dart';
import 'package:vsm_app/widgets/finances_tab_widget.dart';
import 'package:vsm_app/widgets/members_tab_widget.dart';
import 'package:vsm_app/widgets/communication_tab_widget.dart';

class AdminDashboardScreen extends StatefulWidget {
  final EventModel? event;

  const AdminDashboardScreen({super.key, this.event});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  EventModel? _activeEvent;

  // Couleurs de la charte VSM
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color greenDark = Color(0xFF0A1E13);
  static const Color bordeauxRed = Color(0xFF6B1D2F);
  static const Color goldAccent = Color(0xFFD4AF37);

  // URL dynamique multi-plateforme
  String _getBaseUrl() {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.52.90.145:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  @override
  void initState() {
    super.initState();
    _activeEvent = widget.event;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchActiveEvent();
    });
  }

  Future<void> _fetchActiveEvent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      final String baseUrl = _getBaseUrl();

      final eventResponse = await http.get(
        Uri.parse('$baseUrl/events/upcoming'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (eventResponse.statusCode == 200) {
        final rawData = jsonDecode(eventResponse.body);
        final eventData = rawData['data'] ?? rawData;
        if (eventData != null) {
          setState(() {
            _activeEvent = EventModel.fromJson(eventData);
            _isLoading = false;
          });
          return;
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      print(">>> Erreur chargement event admin : $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _activeEvent == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: greenPrimary,
          title: const Text("Tableau de bord Administrateur"),
        ),
        body: const Center(child: CircularProgressIndicator(color: goldAccent)),
      );
    }

    final eventTitle = _activeEvent?.title ?? "Événement";

    return DefaultTabController(
      length: 4, // Passage à 4 onglets
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: greenPrimary,
          elevation: 2,
          // Réduction de la hauteur de la barre de titre
          toolbarHeight: 46,
          title: Text(
            "Tableau de bord Administrateur - $eventTitle",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          bottom: const PreferredSize(
            // Hauteur réduite sur mesure pour la barre d'onglets
            preferredSize: Size.fromHeight(40),
            child: TabBar(
              isScrollable:
                  true, // Recommandé pour 4 onglets et plus afin d'éviter le débordement
              indicatorColor: goldAccent,
              indicatorWeight: 2.5,
              labelColor: goldAccent,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              // Espacement ajusté pour les onglets
              labelPadding: EdgeInsets.symmetric(horizontal: 12),
              tabs: [
                Tab(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dashboard_outlined, size: 18),
                      SizedBox(width: 6),
                      Text("Vue d'ensemble"),
                    ],
                  ),
                ),
                Tab(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 18),
                      SizedBox(width: 6),
                      Text('Finances'),
                    ],
                  ),
                ),
                Tab(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_alt_outlined, size: 18),
                      SizedBox(width: 6),
                      Text('Membres'),
                    ],
                  ),
                ),
                Tab(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.campaign_outlined, size: 18),
                      SizedBox(width: 6),
                      Text('Communication'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            // 1. Nouvel onglet : Vue d'ensemble
            OverviewTabWidget(),

            // 2. Widget de l'onglet Finances
            FinancialTabWidget(),

            // 3. Widget de l'onglet Membres
            MembersTabWidget(),

            // 4. Widget de l'onglet Communication
            CommunicationTabWidget(),
          ],
        ),
      ),
    );
  }
}
