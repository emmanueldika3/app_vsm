import 'package:flutter/material.dart';
import 'package:vsm_app/widgets/tresorier/CotisationsManagementWidget.dart';
import 'package:vsm_app/widgets/tresorier/DepensesManagementWidget.dart';

class GestionFinancesScreen extends StatefulWidget {
  const GestionFinancesScreen({super.key});

  @override
  State<GestionFinancesScreen> createState() => _GestionFinancesScreenState();
}

class _GestionFinancesScreenState extends State<GestionFinancesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color goldAccent = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 42, // Hauteur compacte pour la barre principale
        title: const Text(
          "Gestion des Finances - VSM",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        backgroundColor: greenPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            35,
          ), // Hauteur réduite pour le TabBar
          child: TabBar(
            controller: _tabController,
            indicatorColor: goldAccent,
            indicatorWeight: 2.5,
            labelColor: goldAccent,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: "Entrées"),
              Tab(text: "Sorties"),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [CotisationsManagementWidget(), DepensesManagementWidget()],
      ),
    );
  }
}
