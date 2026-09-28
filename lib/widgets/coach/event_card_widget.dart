import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vsm_app/models/event_model.dart';

class EventCardWidget extends StatefulWidget {
  final EventModel event;
  final VoidCallback? onTap;
  final Function(String status)? onPresenceChanged;
  final bool isCoachOrAdmin;
  final Function(Map<String, dynamic> eventData)? onSaveEvent;
  final VoidCallback? onCancelEvent;

  const EventCardWidget({
    super.key,
    required this.event,
    this.onTap,
    this.onPresenceChanged,
    this.isCoachOrAdmin = false,
    this.onSaveEvent,
    this.onCancelEvent,
  });

  @override
  State<EventCardWidget> createState() => _EventCardWidgetState();
}

class _EventCardWidgetState extends State<EventCardWidget> {
  // Couleurs Charte VSM FC
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color greenDark = Color(0xFF0A1E13);
  static const Color bordeauxRed = Color(0xFF6B1D2F);
  static const Color goldAccent = Color(0xFFD4AF37);

  Timer? _timer;
  String? _localPresenceStatus;

  @override
  void initState() {
    super.initState();
    _localPresenceStatus = widget.event.userPresence;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant EventCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.event != oldWidget.event) {
      _localPresenceStatus = widget.event.userPresence;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handlePresenceTap(String statusKey) {
    setState(() {
      _localPresenceStatus = statusKey;
    });
    widget.onPresenceChanged?.call(statusKey);
  }

  // --- OUVERTURE DU FORMULAIRE EN DIALOGUE ---
  void _openEventFormDialog(BuildContext context, {EventModel? eventToEdit}) {
    showDialog(
      context: context,
      builder: (ctx) => _EventFormDialog(
        eventToEdit: eventToEdit,
        onSubmit: (eventData) {
          widget.onSaveEvent?.call(eventData);
        },
      ),
    );
  }

  // Boîte de dialogue de confirmation pour l'annulation
  void _confirmCancelEvent(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmer l\'annulation'),
        content: const Text('Voulez-vous vraiment annuler cet événement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Non', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: bordeauxRed),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onCancelEvent?.call();
            },
            child: const Text(
              'Oui, annuler',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- MENU CENTRALISÉ SOUS FORME DE PETIT RECTANGLE ---
  void _showAdminMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Gestion de l'événement",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: greenDark,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 1. Bouton Ajouter (Vert VSM)
                  _buildActionIconButton(
                    icon: Icons.add_circle_outline,
                    label: "Ajouter",
                    color: greenPrimary,
                    onTap: () {
                      Navigator.pop(ctx);
                      _openEventFormDialog(context);
                    },
                  ),
                  // 2. Bouton Modifier (Or/Orange)
                  _buildActionIconButton(
                    icon: Icons.edit_outlined,
                    label: "Modifier",
                    color: goldAccent,
                    onTap: () {
                      Navigator.pop(ctx);
                      _openEventFormDialog(context, eventToEdit: widget.event);
                    },
                  ),
                  // 3. Bouton Annuler (Bordeaux)
                  _buildActionIconButton(
                    icon: Icons.cancel_outlined,
                    label: "Annuler",
                    color: bordeauxRed,
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmCancelEvent(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIconButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.event.timeRemaining.isNegative
        ? Duration.zero
        : widget.event.timeRemaining;

    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    final homeName = widget.event.homeTeam ?? "VSM FC";
    final awayName = widget.event.awayTeam ?? "Adversaire";
    final eventType = widget.event.type ?? widget.event.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- TITRE DE SECTION AVEC MENU 3 POINTS (COACH/ADMIN) ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.event_available_rounded,
                    color: greenPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Prochain $eventType",
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (widget.isCoachOrAdmin)
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.black,
                  size: 24,
                ),
                onPressed: () => _showAdminMenu(context),
              ),
          ],
        ),

        const SizedBox(height: 8),

        // --- CARTE DE L'ÉVÉNEMENT ---
        InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [greenPrimary, greenDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: goldAccent.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: goldAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.event.title.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: greenDark,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.event.statusBadge,
                        style: const TextStyle(
                          color: goldAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white12,
                              backgroundImage: widget.event.homeLogoUrl != null
                                  ? NetworkImage(widget.event.homeLogoUrl!)
                                  : null,
                              child: widget.event.homeLogoUrl == null
                                  ? const Icon(
                                      Icons.sports_soccer,
                                      color: goldAccent,
                                      size: 28,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              homeName,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "VS",
                          style: TextStyle(
                            color: goldAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white12,
                              backgroundImage: widget.event.awayLogoUrl != null
                                  ? NetworkImage(widget.event.awayLogoUrl!)
                                  : null,
                              child: widget.event.awayLogoUrl == null
                                  ? const Icon(
                                      Icons.shield,
                                      color: Colors.white70,
                                      size: 28,
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              awayName,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTimerUnit(
                          days.toString().padLeft(2, '0'),
                          "Jours",
                        ),
                        _buildTimerSeparator(),
                        _buildTimerUnit(
                          hours.toString().padLeft(2, '0'),
                          "Heures",
                        ),
                        _buildTimerSeparator(),
                        _buildTimerUnit(
                          minutes.toString().padLeft(2, '0'),
                          "Min",
                        ),
                        _buildTimerSeparator(),
                        _buildTimerUnit(
                          seconds.toString().padLeft(2, '0'),
                          "Sec",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: goldAccent,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "${widget.event.eventDateTime.day.toString().padLeft(2, '0')}/${widget.event.eventDateTime.month.toString().padLeft(2, '0')}/${widget.event.eventDateTime.year} • ${widget.event.eventDateTime.hour}h${widget.event.eventDateTime.minute.toString().padLeft(2, '0')}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: goldAccent,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.event.venue,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Divider(
                    color: Colors.white24,
                    height: 20,
                    thickness: 1,
                  ),

                  const Text(
                    "VOTRE PRÉSENCE",
                    style: TextStyle(
                      color: goldAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPresenceButton(
                          label: "Présent",
                          statusKey: "present",
                          icon: Icons.check_circle,
                          activeColor: greenPrimary,
                          activeTextColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildPresenceButton(
                          label: "Incertain",
                          statusKey: "uncertain",
                          icon: Icons.help,
                          activeColor: goldAccent,
                          activeTextColor: greenDark,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildPresenceButton(
                          label: "Absent",
                          statusKey: "absent",
                          icon: Icons.cancel,
                          activeColor: bordeauxRed,
                          activeTextColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresenceButton({
    required String label,
    required String statusKey,
    required IconData icon,
    required Color activeColor,
    required Color activeTextColor,
  }) {
    final isSelected = _localPresenceStatus == statusKey;

    return ElevatedButton(
      onPressed: () => _handlePresenceTap(statusKey),
      style: ButtonStyle(
        elevation: WidgetStateProperty.all(isSelected ? 2 : 0),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected
                  ? Colors.white
                  : activeColor.withValues(alpha: 0.5),
              width: isSelected ? 1.5 : 1,
            ),
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (isSelected) return activeColor;
          return Colors.black26;
        }),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 13,
            color: isSelected ? activeTextColor : activeColor,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? activeTextColor : Colors.white70,
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerUnit(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: goldAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9)),
      ],
    );
  }

  Widget _buildTimerSeparator() {
    return const Text(
      ":",
      style: TextStyle(
        color: Colors.white38,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }
}

// ==========================================
// FORMULAIRE DIALOG INTERNE (AJOUT / EDIT)
// ==========================================
class _EventFormDialog extends StatefulWidget {
  final EventModel? eventToEdit;
  final Function(Map<String, dynamic> eventData) onSubmit;

  const _EventFormDialog({this.eventToEdit, required this.onSubmit});

  @override
  State<_EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<_EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _homeTeamController;
  late TextEditingController _awayTeamController;
  late TextEditingController _venueController;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.eventToEdit?.title ?? '',
    );
    _homeTeamController = TextEditingController(
      text: widget.eventToEdit?.homeTeam ?? 'VSM FC',
    );
    _awayTeamController = TextEditingController(
      text: widget.eventToEdit?.awayTeam ?? '',
    );
    _venueController = TextEditingController(
      text: widget.eventToEdit?.venue ?? '',
    );
    _selectedDateTime =
        widget.eventToEdit?.eventDateTime ??
        DateTime.now().add(const Duration(days: 3));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _homeTeamController.dispose();
    _awayTeamController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventToEdit != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEditing ? 'Modifier l\'événement' : 'Nouvel événement'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre (ex: Match, Entraînement)',
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _homeTeamController,
                decoration: const InputDecoration(labelText: 'Équipe Domicile'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _awayTeamController,
                decoration: const InputDecoration(
                  labelText: 'Équipe Extérieure / Adversaire',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(labelText: 'Lieu / Stade'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Date : ${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} à ${_selectedDateTime.hour}h${_selectedDateTime.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickDateTime,
                    icon: const Icon(Icons.calendar_today, size: 14),
                    label: const Text(
                      'Modifier',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E5235),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final data = {
                'title': _titleController.text,
                'homeTeam': _homeTeamController.text,
                'awayTeam': _awayTeamController.text,
                'venue': _venueController.text,
                'eventDateTime': _selectedDateTime.toIso8601String(),
              };
              widget.onSubmit(data);
              Navigator.pop(context);
            }
          },
          child: Text(
            isEditing ? 'Mettre à jour' : 'Créer',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
