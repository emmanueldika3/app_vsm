import 'package:flutter/material.dart';

class EffectifStatusWidget extends StatelessWidget {
  final int availableCount;
  final int uncertainCount;
  final int unavailableCount;
  final VoidCallback? onTapAvailable;
  final VoidCallback? onTapUncertain;
  final VoidCallback? onTapUnavailable;

  const EffectifStatusWidget({
    super.key,
    required this.availableCount,
    required this.uncertainCount,
    required this.unavailableCount,
    this.onTapAvailable,
    this.onTapUncertain,
    this.onTapUnavailable,
  });

  // Couleurs Charte VSM FC
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color bordeauxRed = Color(0xFF6B1D2F);
  static const Color goldAccent = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final total = availableCount + uncertainCount + unavailableCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête de la section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.groups_rounded, color: greenPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  "État de l'effectif",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            Text(
              "$total réponses",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Cartes des compteurs
        Row(
          children: [
            Expanded(
              child: _buildCountCard(
                title: "Disponibles",
                count: availableCount,
                color: greenPrimary,
                icon: Icons.check_circle_outline,
                onTap: onTapAvailable,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCountCard(
                title: "Incertains",
                count: uncertainCount,
                color: goldAccent,
                icon: Icons.help_outline,
                onTap: onTapUncertain,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCountCard(
                title: "Indisponibles",
                count: unavailableCount,
                color: bordeauxRed,
                icon: Icons.highlight_off,
                onTap: onTapUnavailable,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCountCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
