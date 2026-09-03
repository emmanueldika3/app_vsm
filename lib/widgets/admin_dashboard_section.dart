// lib/widgets/admin_stats_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';

class AdminStatsWidget extends StatefulWidget {
  const AdminStatsWidget({super.key});

  @override
  State<AdminStatsWidget> createState() => _AdminStatsWidgetState();
}

class _AdminStatsWidgetState extends State<AdminStatsWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminDashboardProvider>();
    final data = adminProvider.dashboardData;

    // 1. État de Chargement
    if (adminProvider.isLoading) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF1E5235), strokeWidth: 3),
            SizedBox(height: 12),
            Text(
              "Chargement des données depuis la base...",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // 2. Gestion des Erreurs
    if (data == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFCDD2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Impossible de charger les statistiques du tableau de bord.",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  context.read<AdminDashboardProvider>().fetchDashboardData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    // Extraction dynamique pour éviter tout conflit de types/champs
    final membersDyn = data.membersOverview as dynamic;
    final financialDyn = data.financialOverview as dynamic;

    // Lecture sécurisée des valeurs
    final activeMembers = (membersDyn.activeMembers ?? 0).toString().padLeft(
      2,
      '0',
    );
    final newThisMonth = (membersDyn.newThisMonth ?? 0).toString();
    final totalCollected = (financialDyn.totalCollected ?? 0.0).toStringAsFixed(
      0,
    );

    // 3. Affichage des 4 cartes d'origine
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Text(
            "Aperçu Général",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E5235),
              letterSpacing: 0.3,
            ),
          ),
        ),

        // Grille des 4 cartes
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.35,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // 1. Membres Actifs
            _buildStatCard(
              title: "Membres Actifs",
              value: activeMembers,
              icon: Icons.people_alt_rounded,
              color: const Color(0xFF1E5235),
              bgGradient: const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
              actionWidget: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/add-member');
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E5235),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: Colors.white),
                      SizedBox(width: 2),
                      Text(
                        "Ajouter",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Demandes en attente
            _buildStatCard(
              title: "Demandes en attente",
              value: newThisMonth,
              icon: Icons.person_add_alt_1_rounded,
              color: const Color(0xFFE65100),
              bgGradient: const [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
            ),

            // 3. Solde Caisse
            _buildStatCard(
              title: "Solde Caisse",
              value: "$totalCollected XAF",
              icon: Icons.account_balance_wallet_rounded,
              color: const Color(0xFF1565C0),
              bgGradient: const [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            ),

            // 4. Événements à venir
            _buildStatCard(
              title: "Événements à venir",
              value: "${data.eventsOverview.upcomingEvents}",
              icon: Icons.event_available_rounded,
              color: const Color(0xFF00796B),
              bgGradient: const [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
            ),
          ],
        ),
      ],
    );
  }

  // Composant Carte Individuelle
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required List<Color> bgGradient,
    Widget? actionWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: bgGradient),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (actionWidget != null) actionWidget,
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
