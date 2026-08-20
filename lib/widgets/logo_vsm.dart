import 'package:flutter/material.dart';

class VsmLogo extends StatelessWidget {
  final double size;
  final Color borderColor;

  const VsmLogo({
    super.key,
    this.size = 38.0,
    this.borderColor = const Color(0xFFD4AF37), // Couleur goldAccent par défaut
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        // color: Colors.white,
        shape: BoxShape.circle,
        // border: Border.all(color: borderColor, width: 1.0),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo_vsm.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.sports_soccer,
            color: Theme.of(context).primaryColor,
            size: size * 0.55,
          ),
        ),
      ),
    );
  }
}
