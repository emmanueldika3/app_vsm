import 'package:flutter/material.dart';
import 'package:vsm_app/models/event_model.dart';
import 'package:vsm_app/widgets/coach/squad_effectif_widget.dart'; // Import du widget d'effectif

class SquadTabWidget extends StatelessWidget {
  final EventModel event;

  const SquadTabWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          "Gestion de l'Effectif - ${event.title}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // Appel de SquadEffectifWidget en lui injectant l'événement
        SquadEffectifWidget(),
      ],
    );
  }
}
