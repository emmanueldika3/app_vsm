import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsm_app/widgets/coach/overview_tab_widget.dart';
import 'package:vsm_app/widgets/coach/tactics_tab_widget.dart';
import 'package:vsm_app/widgets/coach/squad_tab_widget.dart';
import 'package:vsm_app/widgets/coach/finances_com_tab_widget.dart';
import 'package:vsm_app/models/event_model.dart';

class CoachDashboardScreen extends StatefulWidget {
  final EventModel? event;

  const CoachDashboardScreen({super.key, this.event});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color goldAccent = Color(0xFFD4AF37);

  late Future<EventModel?> _eventFuture;

  @override
  void initState() {
    super.initState();
    _eventFuture = _fetchRealUpcomingEvent();
  }

  String _getApiBaseUrl() {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (Platform.isAndroid) return 'http://10.52.90.145:8000/api';
    return 'http://127.0.0.1:8000/api';
  }

  Future<EventModel?> _fetchRealUpcomingEvent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token =
          prefs.getString('auth_token') ?? prefs.getString('token') ?? '';
      final baseUrl = _getApiBaseUrl();

      final response = await http.get(
        Uri.parse('$baseUrl/events/upcoming'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final eventObj = jsonResponse['data'];
        if (eventObj != null) {
          return EventModel.fromJson(eventObj);
        }
      }
    } catch (e) {
      debugPrint("Erreur chargement event: $e");
    }
    return widget.event; // Retourne l'événement transmis si l'API échoue
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EventModel?>(
      future: _eventFuture,
      builder: (context, snapshot) {
        // Si l'API charge encore, on affiche un loader propre dans l'AppBar ou le corps
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: greenPrimary,
              title: const Text(
                "Chargement de l'événement...",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(color: greenPrimary),
            ),
          );
        }

        // On récupère le vrai événement chargé, ou celui par défaut en dernier recours
        final currentEvent =
            snapshot.data ??
            widget.event ??
            EventModel(
              id: 0,
              title: "Tableau de bord Coach",
              type: "match",
              eventDateTime: DateTime.now(),
              venue: "Stade",
            );

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: greenPrimary,
              elevation: 2,
              toolbarHeight: 46,
              title: Text(
                "Tableau de bord Coach - ${currentEvent.title}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: TabBar(
                  isScrollable: true,
                  indicatorColor: goldAccent,
                  indicatorWeight: 2.5,
                  labelColor: goldAccent,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                  tabs: const [
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
                          Icon(Icons.sports_soccer_outlined, size: 18),
                          SizedBox(width: 6),
                          Text('Tactique'),
                        ],
                      ),
                    ),
                    Tab(
                      height: 36,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.groups_outlined, size: 18),
                          SizedBox(width: 6),
                          Text('Effectif'),
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
                          Text('Finances & Com'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              children: [
                const OverviewTabWidget(),
                const TacticalTabWidget(),
                SquadTabWidget(event: currentEvent),
                const FinancesComTabWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}
