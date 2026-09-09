import 'package:flutter/material.dart';

class PendingRequestsCard extends StatelessWidget {
  final String pendingCount;

  const PendingRequestsCard({super.key, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(
            Icons.person_add_alt_1_rounded,
            color: Color(0xFFE65100),
            size: 24,
          ),
          const SizedBox(height: 8),
          const Text(
            "Demandes en attente",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFE65100),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            pendingCount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE65100),
            ),
          ),
        ],
      ),
    );
  }
}
