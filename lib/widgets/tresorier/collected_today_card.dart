import 'package:flutter/material.dart';

class CollectedTodayCard extends StatelessWidget {
  final double totalCollected;
  final String currency;
  final bool isLoading;

  const CollectedTodayCard({
    super.key,
    required this.totalCollected,
    this.currency = 'FCFA',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF8F6B00);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ), // Padding réduit pour éviter l'overflow
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: themeColor,
                  size: 16,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Collecté (Jour)",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: themeColor.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              if (isLoading)
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                  ),
                )
              else
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${totalCollected.toStringAsFixed(0)} $currency",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
