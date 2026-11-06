import 'package:flutter/material.dart';

class UpToDateMembersCard extends StatelessWidget {
  final int upToDateCount;
  final int membersCount;
  final bool isLoading;

  const UpToDateMembersCard({
    super.key,
    required this.upToDateCount,
    required this.membersCount,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF1E5235);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ), // Padding réduit
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
                  Icons.how_to_reg,
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
                "Membres à jour",
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
                    "$upToDateCount / $membersCount",
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
