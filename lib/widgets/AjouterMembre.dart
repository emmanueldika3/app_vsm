import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddUserDialog extends StatefulWidget {
  final VoidCallback? onSuccess;

  const AddUserDialog({Key? key, this.onSuccess}) : super(key: key);

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  // Charte graphique VSM
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color greenDark = Color(0xFF0A1E13);
  static const Color bordeauxRed = Color(0xFF6B1D2F);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color neutralBg = Color(0xFFF8F9FA);

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: "Samuel Etoo");
  final _phoneController = TextEditingController(text: "+237690000000");
  final _emailController = TextEditingController(text: "etoo@vsm.com");
  final _passwordController = TextEditingController(text: "Secret123!");
  final _jerseyController = TextEditingController(text: "9");
  final _photoUrlController = TextEditingController();

  String _role = 'player';
  String _status = 'active';
  bool _isActive = true;
  String _position = 'Attaquant';
  bool _isLoading = false;

  final Map<String, String> _roleLabels = {
    'admin': 'Admin',
    'player': 'Joueur',
    'coach': 'Coach',
    'treasurer': 'Trésorier',
  };

  final List<String> _statuses = ['active', 'suspended', 'pending'];
  final List<String> _positions = [
    'Attaquant',
    'Milieu',
    'Défenseur',
    'Gardien',
    'Staff',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _jerseyController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final bodyData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'role': _role,
      'status': _status,
      'is_active': _isActive,
      'jersey_number': _jerseyController.text.isNotEmpty
          ? int.tryParse(_jerseyController.text)
          : null,
      'position': _position,
      'photo_url': _photoUrlController.text.trim().isNotEmpty
          ? _photoUrlController.text.trim()
          : null,
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Vérification explicite de la présence du token Sanction/Bearer
      if (token == null || token.isEmpty) {
        throw Exception(
          'Jeton d\'authentification manquant. Veuillez vous recharger la session.',
        );
      }

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/users'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Membre VSM enregistré avec succès !'),
              backgroundColor: greenPrimary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          widget.onSuccess?.call();
        }
      } else {
        // Extraction sécurisée des erreurs retournées par Laravel
        String errorMessage = 'Erreur serveur (${response.statusCode})';
        try {
          final error = jsonDecode(response.body);
          if (error is Map<String, dynamic>) {
            errorMessage = error['message'] ?? error['error'] ?? errorMessage;
          }
        } catch (_) {
          // En cas de réponse HTML (ex: 500 Fatal Error)
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: bordeauxRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _customInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 13),
      prefixIcon: Icon(icon, color: greenPrimary, size: 18),
      fillColor: neutralBg,
      filled: true,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: greenPrimary, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: bordeauxRed, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: bordeauxRed, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: greenPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person_add_outlined,
                        color: greenPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Nouveau Membre VSM',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: greenDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Champs Identité
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 13),
                  decoration: _customInputDecoration(
                    'Nom complet *',
                    Icons.person_outline,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nom requis' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        style: const TextStyle(fontSize: 13),
                        decoration: _customInputDecoration(
                          'Téléphone *',
                          Icons.phone_outlined,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        style: const TextStyle(fontSize: 13),
                        decoration: _customInputDecoration(
                          'Email *',
                          Icons.email_outlined,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v == null || !v.contains('@') ? 'Invalide' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  style: const TextStyle(fontSize: 13),
                  decoration: _customInputDecoration(
                    'Mot de passe *',
                    Icons.lock_outline,
                  ),
                  obscureText: true,
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Min. 6 caractères' : null,
                ),
                const SizedBox(height: 16),

                // Section Profil VSM
                const Text(
                  'Profil & Rôle VSM',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: greenPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _role,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                        decoration: _customInputDecoration(
                          'Rôle',
                          Icons.security_outlined,
                        ),
                        items: _roleLabels.entries
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _role = v!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _position,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                        decoration: _customInputDecoration(
                          'Poste',
                          Icons.sports_soccer_outlined,
                        ),
                        items: _positions
                            .map(
                              (p) => DropdownMenuItem(value: p, child: Text(p)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _position = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _jerseyController,
                        style: const TextStyle(fontSize: 13),
                        decoration: _customInputDecoration(
                          'N° Maillot',
                          Icons.tag,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _status,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                        decoration: _customInputDecoration(
                          'Statut',
                          Icons.info_outline,
                        ),
                        items: _statuses
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _status = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _photoUrlController,
                  style: const TextStyle(fontSize: 13),
                  decoration: _customInputDecoration(
                    'URL Photo (Optionnel)',
                    Icons.image_outlined,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Compte Actif',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: greenDark,
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _isActive,
                          activeColor: goldAccent,
                          activeTrackColor: greenPrimary,
                          onChanged: (val) => setState(() => _isActive = val),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Boutons d'action
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Enregistrer',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
