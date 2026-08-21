// lib/widgets/create_event_dialog.dart
import 'package:flutter/material.dart';

enum EventType { match, training }

class CreateEventDialog extends StatefulWidget {
  final Function(Map<String, dynamic> eventData) onSubmit;

  const CreateEventDialog({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _CreateEventDialogState createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  final _formKey = GlobalKey<FormState>();
  EventType _eventType = EventType.training;
  String _title = '';
  String _location = 'Stade de Mahèn';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  String _description = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Programmer une activité'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<EventType>(
                value: _eventType,
                decoration: const InputDecoration(
                  labelText: 'Type d\'activité',
                ),
                items: const [
                  DropdownMenuItem(
                    value: EventType.training,
                    child: Text('Entraînement Dominical'),
                  ),
                  DropdownMenuItem(
                    value: EventType.match,
                    child: Text('Match Amical / Officiel'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _eventType = val);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Titre / Adversaire',
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Champ requis' : null,
                onSaved: (val) => _title = val!,
              ),
              TextFormField(
                initialValue: _location,
                decoration: const InputDecoration(labelText: 'Lieu'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Champ requis' : null,
                onSaved: (val) => _location = val!,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Changer'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text('Heure: ${_selectedTime.format(context)}'),
                  ),
                  TextButton(
                    onPressed: _pickTime,
                    child: const Text('Changer'),
                  ),
                ],
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Consignes / Description',
                ),
                maxLines: 2,
                onSaved: (val) => _description = val ?? '',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
          onPressed: _submit,
          child: const Text('Publier & Notifier'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final eventData = {
        'type': _eventType == EventType.training ? 'entraînement' : 'match',
        'title': _title,
        'location': _location,
        'date': _selectedDate.toIso8601String(),
        'time': '${_selectedTime.hour}:${_selectedTime.minute}',
        'description': _description,
      };
      widget.onSubmit(eventData);
      Navigator.pop(context);
    }
  }
}
