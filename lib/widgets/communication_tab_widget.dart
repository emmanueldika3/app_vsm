import 'package:flutter/material.dart';
import 'package:vsm_app/widgets/announcements_widget.dart';

class CommunicationTabWidget extends StatelessWidget {
  const CommunicationTabWidget({super.key});

  // Couleurs de la charte VSM
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color bordeauxRed = Color(0xFF6B1D2F);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Centre de Communication & Annonces",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: greenPrimary,
            ),
          ),
          SizedBox(height: 12),

          // Intégration du composant des annonces et communiqués
          AnnouncementsWidget(),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
