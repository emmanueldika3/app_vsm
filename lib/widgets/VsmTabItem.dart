import 'package:flutter/material.dart';

class VsmTabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int notificationCount;

  const VsmTabItem({
    super.key,
    required this.icon,
    required this.label,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
          if (notificationCount > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$notificationCount',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
