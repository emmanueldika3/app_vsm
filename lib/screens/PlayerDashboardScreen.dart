import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsm_app/widgets/coach/overview_tab_widget.dart';
import 'package:vsm_app/widgets/coach/finances_com_tab_widget.dart';
import 'package:vsm_app/widgets/coach/squad_tab_widget.dart';
import 'package:vsm_app/widgets/player/PlayerTacticalFieldWidget.dart';
import 'package:vsm_app/models/event_model.dart';
import 'package:vsm_app/models/prensentPlayers.dart';

class PlayerDashboardScreen extends StatefulWidget {
  final EventModel event;

  PlayerDashboardScreen({super.key, required this.event}) {
    print(">>> LE CONSTRUCTEUR DE PLAYERDASHBOARDSCREEN A ÉTÉ APPELÉ ! <<<");
  }

  @override
  State<PlayerDashboardScreen> createState() => _PlayerDashboardScreenState();
}

class _PlayerDashboardScreenState extends State<PlayerDashboardScreen> {
  bool _isLoading = true;
  late EventModel _activeEvent;
  String _selectedFormation = "4-3-3";
  Map<String, PresentPlayer> _assignedPlayers = {};
  List<PresentPlayer> _substitutePlayers = [];
  PresentPlayer? _connectedPlayer;

  // Couleurs de la charte VSM FC
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color goldAccent = Color(0xFFD4AF37);

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
      _fetchActiveEventAndTactics();
    });
  }

  Future<void> _fetchActiveEventAndTactics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      final String baseUrl = _getBaseUrl();

      final eventResponse = await http.get(
        Uri.parse('$baseUrl/events/upcoming'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (eventResponse.statusCode == 200) {
        final rawData = jsonDecode(eventResponse.body);
        final eventData = rawData['data'] ?? rawData;

        if (eventData != null) {
          setState(() {
            _activeEvent = EventModel.fromJson(eventData);
          });
        }

        final int? activeEventId = _activeEvent.id;
        if (activeEventId == null) {
          setState(() => _isLoading = false);
          return;
        }

        final tacticResponse = await http.get(
          Uri.parse('$baseUrl/events/$activeEventId/tactics'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (tacticResponse.statusCode == 200) {
          final data = jsonDecode(tacticResponse.body);

          setState(() {
            _selectedFormation = data['formation'] ?? "4-3-3";
            _assignedPlayers.clear();
            _substitutePlayers.clear();

            List<dynamic> startingXi = data['starting_xi'] ?? [];
            for (var item in startingXi) {
              String position = item['position'] ?? 'CM';
              var player = PresentPlayer.fromJson(item);
              _assignedPlayers[position] = player;
            }

            List<dynamic> substitutes = data['substitutes'] ?? [];
            for (var item in substitutes) {
              try {
                var player = PresentPlayer.fromJson(item);
                _substitutePlayers.add(player);
              } catch (e) {
                print(">>> Erreur parsing remplaçant : $e");
              }
            }

            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print(">>> Erreur chargement : $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: greenPrimary,
          elevation: 2,
          toolbarHeight: 46,
          titleSpacing: 16.0,
          title: const Text(
            "Chargement de l'événement...",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator(color: goldAccent)),
      );
    }

    final currentEvent = _activeEvent;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: greenPrimary,
          elevation: 2,
          toolbarHeight: 46,
          automaticallyImplyLeading: false,
          titleSpacing: 16.0,
          title: Text(
            "Tableau de bord Joueur - ${currentEvent.title}",
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
                      Text('Coéquipiers'),
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
            PlayerTacticsTabWidget(
              event: currentEvent,
              selectedFormation: _selectedFormation,
              assignedPlayers: _assignedPlayers,
              substitutePlayers: _substitutePlayers,
              connectedPlayer: _connectedPlayer,
            ),
            SquadTabWidget(event: currentEvent),
            const FinancesComTabWidget(),
          ],
        ),
      ),
    );
  }
}
