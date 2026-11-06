import 'package:flutter/material.dart';

class VsmLogo extends StatelessWidget {
  final double size;
  final Color borderColor;

  const VsmLogo({
    super.key,
    this.size =
        250.0, // Taille augmentée par défaut pour une affiche plus grande
    this.borderColor = const Color(0xFFD4AF37), // Couleur goldAccent par défaut
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(
        16,
      ), // Ajout de rembourrage pour que le logo soit bien contenu
      decoration: BoxDecoration(
        color: Colors.white, // Fond blanc solide pour que le logo ressorte
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 4.0,
        ), // Bordure plus épaisse pour l'affiche
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4), // Ombre portée pour un effet premium
          ),
        ],
      ),
      child: Center(
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo_vsm.png',
            fit: BoxFit.contain, // Assure que le logo est entièrement visible
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.sports_soccer,
              color: Theme.of(context).primaryColor,
              size: size * 0.55, // Adapte la taille de l'icône de remplacement
            ),
          ),
        ),
      ),
    );
  }
}
