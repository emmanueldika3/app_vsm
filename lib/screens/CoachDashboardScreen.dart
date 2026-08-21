// lib/screens/coach_dashboard.dart
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../widgets/create_event_dialog.dart';
import '../widgets/players_list_widget.dart';
import '../widgets/announcements_widget.dart';

class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen>
    with SingleTickerProviderStateMixin {
  // Charte Graphique VSM
  static const Color greenPrimary = Color(0xFF1B5E20);
  static const Color bordeauxRed = Color(0xFF6B1D2F);
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color lightBg = Color(0xFFF8F9FA);

  late TabController _tabController;
  int _currentIndex = 0;
  final String _apiUrl =
      'https://votre-api-laravel.com'; // URL de votre API Backend

  // Communiqués de l'administration
  final List<Map<String, String>> _adminAnnouncements = [
    {
      'title': 'Assemblée Générale Extraordinaire',
      'content': 'Réunion obligatoire après la séance dominicale à 10h00.',
      'date': '18/08/2026',
    },
    {
      'title': 'Cotisations mensuelles',
      'content': 'Merci d\'être à jour pour la séance de ce dimanche.',
      'date': '15/08/2026',
    },
  ];

  // Séance ou Match en cours
  Map<String, dynamic> _currentSession = {
    'title': 'SÉANCE DOMINICALE',
    'opponent': 'Entraînement Interne',
    'date': 'Dimanche, 06h30',
    'location': 'Stade PK11',
    'type': 'training',
  };

  // Liste locale / d'état pour la gestion de présence et de composition tactique
  final List<Map<String, dynamic>> _players = [
    {
      'id': '1',
      'name': 'Eto\'o Samuel',
      'position': 'Attaquant',
      'number': 9,
      'status': 'present',
      'isStarter': true,
    },
    {
      'id': '2',
      'name': 'Song Rigobert',
      'position': 'Défenseur',
      'number': 4,
      'status': 'present',
      'isStarter': true,
    },
    {
      'id': '3',
      'name': 'Kameni Idriss',
      'position': 'Gardien',
      'number': 1,
      'status': 'present',
      'isStarter': true,
    },
    {
      'id': '4',
      'name': 'Mbami Modeste',
      'position': 'Milieu',
      'number': 8,
      'status': 'late',
      'isStarter': false,
    },
    {
      'id': '5',
      'name': 'Geremi Njitap',
      'position': 'Défenseur',
      'number': 12,
      'status': 'present',
      'isStarter': true,
    },
    {
      'id': '6',
      'name': 'Achille Webó',
      'position': 'Attaquant',
      'number': 15,
      'status': 'absent',
      'isStarter': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Calculs des présences
  int get _presentCount =>
      _players.where((p) => p['status'] == 'present').length;
  int get _lateCount => _players.where((p) => p['status'] == 'late').length;
  int get _absentCount => _players.where((p) => p['status'] == 'absent').length;
  int get _starterCount => _players.where((p) => p['isStarter'] == true).length;

  void _toggleStarterStatus(Map<String, dynamic> player) {
    bool currentStatus = player['isStarter'] ?? false;
    if (!currentStatus && _starterCount >= 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('11 titulaires maximum sur le terrain !'),
          backgroundColor: bordeauxRed,
        ),
      );
      return;
    }
    setState(() {
      player['isStarter'] = !currentStatus;
    });
  }

  void _handleCreateEvent(Map<String, dynamic> eventData) {
    setState(() {
      _currentSession = eventData;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Activité "${eventData['title']}" créée et notifiée aux joueurs !',
        ),
        backgroundColor: greenPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: greenPrimary,
        elevation: 2,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Direction Technique VSM',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Coach - Terrain PK11',
              style: TextStyle(color: goldAccent, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: goldAccent,
              size: 26,
            ),
            tooltip: 'Programmer un match / séance',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    CreateEventDialog(onSubmit: _handleCreateEvent),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: goldAccent,
          indicatorWeight: 3,
          labelColor: goldAccent,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.fact_check_outlined), text: 'Appel'),
            Tab(icon: Icon(Icons.sports_soccer_outlined), text: 'Tactique'),
            Tab(icon: Icon(Icons.people_outline), text: 'Effectif API'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. COMMUNIQUÉS DE L'ADMINISTRATION
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 6.0,
            ),
            child: AnnouncementsWidget(announcements: _adminAnnouncements),
          ),

          // 2. EN-TÊTE SÉANCE / MATCH DU JOUR
          _buildMatchHeaderCard(),

          // 3. ENSEMBLE DES ONGLETS (APPEL, TACTIQUE, EFFECTIF API)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAttendanceTab(),
                _buildTacticsTab(),
                _buildApiPlayersTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  // Card récapitulative du match ou entraînement programmé
  Widget _buildMatchHeaderCard() {
    bool isMatch = _currentSession['type'] == 'match';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: goldAccent.withAlpha(150)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isMatch
                      ? bordeauxRed.withAlpha(25)
                      : greenPrimary.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _currentSession['title'].toString().toUpperCase(),
                  style: TextStyle(
                    color: isMatch ? bordeauxRed : greenPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                '${_currentSession['date'] ?? ''} - ${_currentSession['location'] ?? 'Stade PK11'}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                'VSM Vétérans',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: greenPrimary,
                ),
              ),
              const Text(
                'VS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: goldAccent,
                ),
              ),
              Text(
                _currentSession['opponent'] ?? 'Séance Interne',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: bordeauxRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ONGLET 1 : FEUILLE D'APPEL (PRESENCES ET RETARDS)
  Widget _buildAttendanceTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              _buildKpiChip(
                label: 'Présents',
                count: _presentCount,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              _buildKpiChip(
                label: 'Retards',
                count: _lateCount,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              _buildKpiChip(
                label: 'Absents',
                count: _absentCount,
                color: bordeauxRed,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: _players.length,
            itemBuilder: (context, index) {
              final player = _players[index];
              return Card(
                elevation: 0.8,
                margin: const EdgeInsets.symmetric(vertical: 3),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: greenPrimary,
                    child: Text(
                      '#${player['number']}',
                      style: const TextStyle(
                        color: goldAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(
                    player['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    player['position'],
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'present', label: Text('P')),
                      ButtonSegment(value: 'late', label: Text('R')),
                      ButtonSegment(value: 'absent', label: Text('A')),
                    ],
                    selected: {player['status']},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        player['status'] = newSelection.first;
                      });
                    },
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKpiChip({
    required String label,
    required int count,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(75)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ONGLET 2 : TACTIQUE & 11 ENTRANT
  Widget _buildTacticsTab() {
    final starters = _players.where((p) => p['isStarter'] == true).toList();
    final substitutes = _players.where((p) => p['isStarter'] != true).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Représentation visuelle du terrain
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: greenPrimary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: goldAccent, width: 2),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_soccer, color: goldAccent, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    'COMPOSITION TACTIQUE - (${starters.length}/11 Titulaires)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '11 Titulaires',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: greenPrimary,
              fontSize: 14,
            ),
          ),
          ...starters.map((player) => _buildTacticPlayerTile(player, true)),
          const SizedBox(height: 12),
          const Text(
            'Remplaçants',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: bordeauxRed,
              fontSize: 14,
            ),
          ),
          ...substitutes.map((player) => _buildTacticPlayerTile(player, false)),
        ],
      ),
    );
  }

  Widget _buildTacticPlayerTile(Map<String, dynamic> player, bool isStarter) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        title: Text(
          player['name'],
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(
          player['position'],
          style: const TextStyle(fontSize: 11),
        ),
        trailing: TextButton(
          onPressed: () => _toggleStarterStatus(player),
          child: Text(
            isStarter ? 'Retirer' : 'Titulariser',
            style: TextStyle(
              color: isStarter ? bordeauxRed : greenPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ONGLET 3 : JOUEURS DISPONIBLES DEPUIS L'API
  Widget _buildApiPlayersTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Effectif Enregistré (API)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: greenPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: PlayersListWidget(apiUrl: _apiUrl)),
        ],
      ),
    );
  }
}
