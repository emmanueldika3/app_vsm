import 'package:flutter/material.dart';

class UpcomingEventsCard extends StatelessWidget {
  final String upcomingEvents;

  const UpcomingEventsCard({super.key, required this.upcomingEvents});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
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
            Icons.event_available_rounded,
            color: Color(0xFF00796B),
            size: 24,
          ),
          const SizedBox(height: 8),
          const Text(
            "Événements à venir",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF00796B),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            upcomingEvents,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00796B),
            ),
          ),
        ],
      ),
    );
  }
}
