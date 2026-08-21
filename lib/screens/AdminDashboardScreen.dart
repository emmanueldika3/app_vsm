import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Imports de tes widgets et providers
import 'package:vsm_app/widgets/logo_vsm.dart';
import 'package:vsm_app/widgets/avatar.dart';
import 'package:vsm_app/widgets/custom_bottom_navigation_bar.dart';
import 'package:vsm_app/provider/admin_dashboard_provider.dart';
import 'package:vsm_app/provider/auth_provider.dart'; // Pour récupérer le token JWT

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  // Charte graphique VSM
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color bordeauxRed = Color(0xFF6B1D2F);
  static const Color goldAccent = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token =
          Provider.of<AuthProvider>(context, listen: false).token ?? '';
      Provider.of<AdminDashboardProvider>(
        context,
        listen: false,
      ).fetchDashboardData(token);
    });
  }

  void _loadDashboardData() {
    final token = Provider.of<AuthProvider>(context, listen: false).token ?? '';
    Provider.of<AdminDashboardProvider>(
      context,
      listen: false,
    ).fetchDashboardData(token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: greenPrimary,
        toolbarHeight: 90.0,
        elevation: 3,
        titleSpacing: 12,
        title: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;
            final String adminName = user?.fullName ?? 'Admin VSM';
            final String initials = adminName.isNotEmpty
                ? adminName.split(' ').map((e) => e[0]).take(2).join()
                : 'AD';

            return Row(
              children: [
                // 1. Photo de profil dynamique (mode consultation légère)
                UserAvatar(
                  radius: 22,
                  imageUrl: user?.photoUrl,
                  initials: initials,
                  isEditable:
                      true, // Passer à true si tu veux permettre l'édition directe ici
                ),
                const SizedBox(width: 12),

                // 2. Nom de l'admin connecté & Rôle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        adminName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Espace Administration',
                        style: TextStyle(
                          color: goldAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          // 3. Mini Logo VSM dans les actions
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: VsmLogo(size: 44),
          ),
          const SizedBox(width: 4),

          // 4. Bouton Rafraîchir
          IconButton(
            icon: const Icon(Icons.refresh, color: goldAccent, size: 22),
            tooltip: 'Rafraîchir',
            onPressed: _loadDashboardData,
          ),

          // 5. Bouton Notifications avec Badge
          IconButton(
            icon: const Badge(
              smallSize: 8,
              backgroundColor: bordeauxRed,
              child: Icon(
                Icons.notifications_outlined,
                color: goldAccent,
                size: 22,
              ),
            ),
            tooltip: 'Notifications',
            onPressed: () {},
          ),

          // 6. Bouton Paramètres
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: goldAccent,
              size: 22,
            ),
            tooltip: 'Paramètres',
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeDashboardTab(),
          const Center(child: Text('Gestion des Membres')),
          const Center(child: Text('Trésorerie')),
          const Center(child: Text('Annonces')),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  // --- ONGLET 1 : DYNAMIQUE (CONSUMER) ---
  Widget _buildHomeDashboardTab() {
    return Consumer<AdminDashboardProvider>(
      builder: (context, provider, child) {
        // 1. État de Chargement
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: greenPrimary),
          );
        }

        // 2. État d'Erreur
        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: bordeauxRed, size: 48),
                const SizedBox(height: 12),
                Text(
                  provider.error!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenPrimary,
                  ),
                  onPressed: _loadDashboardData,
                  child: const Text(
                    'Réessayer',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        final data = provider.data;
        if (data == null) return const SizedBox.shrink();

        // 3. État de Succès : Affichage des données API
        return RefreshIndicator(
          color: greenPrimary,
          onRefresh: () async => _loadDashboardData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKpiGrid(data),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Demandes d\'adhésion (${data.pendingMembersCount})',
                  () => setState(() => _currentIndex = 1),
                ),
                const SizedBox(height: 12),
                _buildPendingMembersList(data.pendingMembers),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Aperçu Trésorerie (Consultation)',
                  () => setState(() => _currentIndex = 2),
                ),
                const SizedBox(height: 12),
                _buildFinancialOverviewCard(data.financialSummary),
                const SizedBox(height: 24),
                _buildBroadcastButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- COMPOSANTS DE DÉTAILS DYNAMIQUES ---

  Widget _buildKpiGrid(data) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildKpiCard(
          'Membres Actifs',
          '${data.activeMembers}',
          Icons.people,
          greenPrimary,
        ),
        _buildKpiCard(
          'En Attente',
          '${data.pendingMembersCount}',
          Icons.person_add_alt_1,
          bordeauxRed,
        ),
        _buildKpiCard(
          'Caisse Club',
          '${data.clubBalance.toStringAsFixed(0)} F',
          Icons.account_balance_wallet,
          greenPrimary,
        ),
        _buildKpiCard(
          'Taux Cotisation',
          '${data.contributionRate}%',
          Icons.pie_chart,
          goldAccent,
        ),
      ],
    );
  }

  Widget _buildPendingMembersList(List pendingMembers) {
    if (pendingMembers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('Aucune demande d\'adhésion en attente.'),
        ),
      );
    }

    final token = Provider.of<AuthProvider>(context, listen: false).token ?? '';

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pendingMembers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final member = pendingMembers[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: greenPrimary,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              member.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              'Poste: ${member.position} • ${member.createdAt}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: greenPrimary),
                  onPressed: () async {
                    final success = await Provider.of<AdminDashboardProvider>(
                      context,
                      listen: false,
                    ).approveMember(member.id, token);

                    if (mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${member.name} a été validé !'),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: bordeauxRed),
                  onPressed: () {
                    // Logique de refus
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFinancialOverviewCard(summary) {
    final double ratio = summary.totalCount > 0
        ? summary.paidCount / summary.totalCount
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cotisations Mois en cours',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Text(
                '${summary.paidCount} / ${summary.totalCount} À jour',
                style: const TextStyle(
                  color: greenPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.grey.shade200,
            color: greenPrimary,
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Entrées : +${summary.totalIncome.toStringAsFixed(0)} F',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Sorties : -${summary.totalExpenses.toStringAsFixed(0)} F',
                style: const TextStyle(
                  color: bordeauxRed,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: greenPrimary,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: const Text(
            'Voir tout',
            style: TextStyle(color: bordeauxRed, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildBroadcastButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: bordeauxRed,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.campaign, color: Colors.white),
        label: const Text(
          'PUBLIER UN COMMUNIQUÉ OFFICIEL',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => setState(() => _currentIndex = 3),
      ),
    );
  }
}
