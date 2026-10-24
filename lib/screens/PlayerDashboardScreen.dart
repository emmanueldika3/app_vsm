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
  String _selectedFormation = "4-3-3";
  Map<String, PresentPlayer> _assignedPlayers = {};
  List<PresentPlayer> _substitutePlayers = [];
  PresentPlayer? _connectedPlayer;

  // Couleurs de la charte VSM FC
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchActiveEventAndTactics();
    });
  }

  Future<void> _fetchActiveEventAndTactics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      final String baseUrl = _getBaseUrl();

      // 1. Récupérer l'événement à venir (upcoming event)
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
        final int? activeEventId = eventData['id'];

        print(">>> ID de l'événement upcoming récupéré : $activeEventId");

        if (activeEventId == null) {
          setState(() => _isLoading = false);
          return;
        }

        // 2. Récupérer la tactique liée à cet ID exact
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

            // Réinitialisation
            _assignedPlayers.clear();
            _substitutePlayers.clear();
            // _connectedPlayerPosition = null; // Décommentez si vous avez cette variable d'état

            // 3. Traitement du 11 de départ (Titulaire sur le terrain)
            List<dynamic> startingXi = data['starting_xi'] ?? [];
            for (var item in startingXi) {
              String position = item['position'] ?? 'CM';
              var player = PresentPlayer.fromJson(item);
              _assignedPlayers[position] = player;

              // Vérifie si c'est le joueur connecté (via is_connected ou is_me)
              if (item['is_connected'] == true || item['is_me'] == true) {
                // Le joueur est titulaire à la position : position
                print(
                  ">>> Le joueur connecté est titulaire en position : $position",
                );
              }
            }

            List<dynamic> substitutes = data['substitutes'] ?? [];
            print(
              ">>> Données brutes des remplaçants reçues de l'API : $substitutes",
            );

            for (var item in substitutes) {
              try {
                var player = PresentPlayer.fromJson(item);
                _substitutePlayers.add(player);
              } catch (e) {
                print(
                  ">>> Erreur lors du parsing d'un remplaçant : $e sur l'item : $item",
                );
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
      print(">>> Erreur lors du chargement des tactiques : $e");
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
          title: Text("Espace Membre - ${widget.event.title}"),
        ),
        body: const Center(child: CircularProgressIndicator(color: goldAccent)),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: greenPrimary,
          elevation: 2,
          toolbarHeight: 46,
          title: Text(
            "Espace Membre - ${widget.event.title.isNotEmpty ? widget.event.title : 'Événement'}",
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
                      Text('Consignes'),
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
            // 1. Vue d'ensemble
            const OverviewTabWidget(),

            // 2. Consignes (Tactique chargée dynamiquement depuis la BD)
            PlayerTacticsTabWidget(
              event: widget.event,
              selectedFormation: _selectedFormation,
              assignedPlayers: _assignedPlayers,
              substitutePlayers: _substitutePlayers,
              connectedPlayer: _connectedPlayer,
            ),

            // 3. Coéquipiers (Effectif adapté)
            SquadTabWidget(event: widget.event),

            // 4. Finances & Com
            const FinancesComTabWidget(),
          ],
        ),
      ),
    );
  }
}
