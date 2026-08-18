import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class PlayerDashboardScreen extends StatefulWidget {
  const PlayerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PlayerDashboardScreen> createState() => _PlayerDashboardScreenState();
}

class _PlayerDashboardScreenState extends State<PlayerDashboardScreen> {
  int _currentIndex = 0;

  // Storage mémoire pour la compatibilité Web / Mobile sans crash JS
  Uint8List? _profileImageBytes;
  final ImagePicker _picker = ImagePicker();

  // Charte graphique VSM
  static const Color greenHeader = Color(0xFF1E4D31);
  static const Color greenCard = Color(0xFF0F2D1D);
  static const Color goldText = Color(0xFFC8A752);

  // --- SÉLECTION D'IMAGE SÉCURISÉE (WEB & MOBILE) ---
  Future<void> _pickImage() async {
    try {
      // Instanciation directe pour éviter tout problème de variable nulle
      final ImagePicker picker = ImagePicker();

      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _profileImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint("Erreur sélection image : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      // 1. APP BAR
      appBar: AppBar(
        backgroundColor: greenHeader,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {},
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
                child: Icon(Icons.sports_soccer, color: greenHeader, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'VSM PK11',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      // 2. CORPS SÉCURISÉ
      body: IndexedStack(
        index: _currentIndex.clamp(0, 4),
        children: [
          _buildAccueilView(),
          _buildCotisationsView(),
          _buildMatchsView(),
          _buildAnnuaireView(),
          _buildGalerieView(),
        ],
      ),

      // 3. BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex.clamp(0, 4),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: greenHeader,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Cotisations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Matchs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Annuaire',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_outlined),
            label: 'Galerie',
          ),
        ],
      ),
    );
  }

  // --- VUE ACCUEIL ---
  Widget _buildAccueilView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileCard(),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.info_outline,
            text: 'Aucun communiqué officiel pour le moment.',
          ),
          const SizedBox(height: 16),
          _buildEmptySectionCard(text: 'Aucune convocation de match active.'),
          const SizedBox(height: 16),
          _buildCotisationsSummaryCard(),
          const SizedBox(height: 20),
          const Text(
            'Dernières Photos Mises en Ligne',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          _buildEmptySectionCard(
            text: 'Aucune nouvelle photo ajoutée.',
            height: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildCotisationsView() =>
      const Center(child: Text('Statut Cotisations'));
  Widget _buildMatchsView() => const Center(child: Text('Convocations Matchs'));
  Widget _buildAnnuaireView() => const Center(child: Text('Annuaire Membres'));
  Widget _buildGalerieView() => const Center(child: Text('Galerie Photos'));

  // --- CARTE PROFIL CORRIGÉE (AFFICHAGE PAR MEMOIRE BYTES) ---
  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: greenCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                ClipOval(
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.white24,
                    child: _profileImageBytes != null
                        ? Image.memory(_profileImageBytes!, fit: BoxFit.cover)
                        : const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: goldText,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 12,
                      color: greenCard,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Emmanuel Dika',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Membre Effectif - Vétérans Santé Mahèn',
                  style: TextStyle(
                    color: goldText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySectionCard({required String text, double height = 80}) {
    return Container(
      width: double.infinity,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
      ),
    );
  }

  Widget _buildCotisationsSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statut Cotisations (Trésorerie)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Données financières en cours de mise à jour...',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
