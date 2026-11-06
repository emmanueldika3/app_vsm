import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/models/event_model.dart';
import 'package:vsm_app/models/prensentPlayers.dart';
import 'package:vsm_app/provider/Notificationprovider.dart';
import 'package:vsm_app/widgets/coach/overview_tab_widget.dart';
import 'package:vsm_app/widgets/finances_tab_widget.dart';
import 'package:vsm_app/widgets/communication_tab_widget.dart';
import 'package:vsm_app/widgets/coach/squad_tab_widget.dart';
import 'package:vsm_app/widgets/player/PlayerTacticalFieldWidget.dart';
// import 'package:vsm_app/widgets/tresorier/CotisationsManagementWidget.dart';
import 'package:vsm_app/screens/tresorier/gestion_finances_screen.dart';

import 'package:vsm_app/widgets/coach/finances_com_tab_widget.dart';

class TreasurerDashboardScreen extends StatefulWidget {
  final EventModel? event;

  const TreasurerDashboardScreen({super.key, this.event});

  @override
  State<TreasurerDashboardScreen> createState() =>
      _TreasurerDashboardScreenState();
}

class _TreasurerDashboardScreenState extends State<TreasurerDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  EventModel? _activeEvent;
  String _selectedFormation = "4-3-3";
  Map<String, PresentPlayer> _assignedPlayers = {};
  List<PresentPlayer> _substitutePlayers = [];
  PresentPlayer? _connectedPlayer;

  // Contrôleur de sous-onglets principal pour piloter les 5 onglets
  late TabController _mainTabController;

  // Couleurs de la charte VSM
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color goldAccent = Color(0xFFD4AF37);

  String _getBaseUrl() {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.208.55.145:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 5, vsync: this);

    // Écouter le changement d'onglet pour marquer l'onglet comme lu dans le Provider
    _mainTabController.addListener(() {
      if (!_mainTabController.indexIsChanging) {
        Provider.of<NotificationProvider>(
          context,
          listen: false,
        ).markTabAsRead(_mainTabController.index);
      }
    });

    _activeEvent = widget.event;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchActiveEventAndTactics();
    });
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
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
          if (token != null) 'Authorization': 'Bearer $token',
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
      }

      final int? activeEventId = _activeEvent?.id;
      if (activeEventId != null) {
        final tacticResponse = await http.get(
          Uri.parse('$baseUrl/events/$activeEventId/tactics'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );

        if (tacticResponse.statusCode == 200) {
          final data = jsonDecode(tacticResponse.body);

          setState(() {
            _selectedFormation = data['formation'] ?? "4-3-3";
            _assignedPlayers.clear();
            _substitutePlayers.clear();

            final List<dynamic>? startingXi =
                data['starting_xi'] as List<dynamic>?;
            if (startingXi != null) {
              for (var item in startingXi) {
                if (item != null) {
                  String position = item['position'] ?? 'CM';
                  var player = PresentPlayer.fromJson(item);
                  _assignedPlayers[position] = player;
                }
              }
            }

            final List<dynamic>? substitutes =
                data['substitutes'] as List<dynamic>?;
            if (substitutes != null) {
              for (var item in substitutes) {
                try {
                  if (item != null) {
                    var player = PresentPlayer.fromJson(item);
                    _substitutePlayers.add(player);
                  }
                } catch (e) {
                  print(">>> Erreur parsing remplaçant trésorier : $e");
                }
              }
            }
          });
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print(">>> Erreur chargement event/tactics trésorier : $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _activeEvent == null && widget.event == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator(color: goldAccent)),
      );
    }

    final eventTitle =
        _activeEvent?.title ?? widget.event?.title ?? "Événement";
    final currentEvent =
        _activeEvent ??
        widget.event ??
        EventModel(
          id: 0,
          title: eventTitle,
          type: "match",
          eventDateTime: DateTime.now(),
          venue: "Stade",
        );

    // Récupération des compteurs de notifications depuis le Provider global
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final tabNotifications = notificationProvider.tabNotifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: greenPrimary,
        elevation: 2,
        toolbarHeight: 46,
        automaticallyImplyLeading: false,
        title: Text(
          "Tableau de bord Trésorier - ${currentEvent.title}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Barre de navigation principale (5 onglets) avec badges dynamiques
          Container(
            color: greenPrimary,
            child: TabBar(
              controller: _mainTabController,
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
              tabs: [
                Tab(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.dashboard_outlined, size: 18),
                      const SizedBox(width: 6),
                      const Text("Vue d'ensemble"),
                      if ((tabNotifications[0] ?? 0) > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${tabNotifications[0]}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sports_soccer_outlined, size: 18),
                      const SizedBox(width: 6),
                      const Text('Tactique'),
                      if ((tabNotifications[1] ?? 0) > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${tabNotifications[1]}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.groups_outlined, size: 18),
                      const SizedBox(width: 6),
                      const Text('Coéquipiers'),
                      if ((tabNotifications[2] ?? 0) > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${tabNotifications[2]}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      const Text('Finance'),
                      if ((tabNotifications[3] ?? 0) > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${tabNotifications[3]}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.campaign_outlined, size: 18),
                      const SizedBox(width: 6),
                      const Text('Communication'),
                      if ((tabNotifications[4] ?? 0) > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${tabNotifications[4]}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Corps des onglets principaux
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                // 1. Vue d'ensemble
                const OverviewTabWidget(),

                // 2. Tactique
                PlayerTacticsTabWidget(
                  event: currentEvent,
                  selectedFormation: _selectedFormation,
                  assignedPlayers: _assignedPlayers,
                  substitutePlayers: _substitutePlayers,
                  connectedPlayer: _connectedPlayer,
                ),

                // 3. Coéquipiers
                SquadTabWidget(event: currentEvent),

                // 4. Finance (Subdivisé en 2 sous-onglets : Gestion des finances & Suivi financier)
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        color: const Color(0xFF143824),
                        child: TabBar(
                          indicatorColor: goldAccent,
                          indicatorWeight: 2.0,
                          labelColor: goldAccent,
                          unselectedLabelColor: Colors.white70,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          tabs: const [
                            Tab(height: 36, text: 'Gestion des finances'),
                            Tab(height: 36, text: 'Suivi financier'),
                          ],
                        ),
                      ),
                      const Expanded(
                        child: TabBarView(
                          children: [
                            // Sous-onglet 1 : Gestion des finances
                            GestionFinancesScreen(),
                            // Sous-onglet 2 : Suivi financier
                            FinancesComTabWidget(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 5. Communication
                const CommunicationTabWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
