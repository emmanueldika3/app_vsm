// lib/widgets/MemberFullProfileWidget.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsm_app/provider/auth_provider.dart';

class MemberFullProfileWidget extends StatefulWidget {
  const MemberFullProfileWidget({super.key});

  @override
  State<MemberFullProfileWidget> createState() =>
      _MemberFullProfileWidgetState();
}

class _MemberFullProfileWidgetState extends State<MemberFullProfileWidget> {
  Uint8List? _pickedImageBytes;
  static const String _prefAvatarKey = 'saved_user_avatar_base64';

  @override
  void initState() {
    super.initState();
    _loadSavedAvatar();
  }

  Future<void> _loadSavedAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? base64Image = prefs.getString(_prefAvatarKey);
      if (base64Image != null && base64Image.isNotEmpty) {
        setState(() {
          _pickedImageBytes = base64Decode(base64Image);
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement avatar stocké : $e");
    }
  }

  // Formate proprement la date si elle existe, sinon renvoie la valeur brute ou "-"
  String _formatDate(dynamic dateInput) {
    if (dateInput == null) return "-";
    try {
      String dateStr = dateInput.toString().trim();
      if (dateStr.isEmpty || dateStr == "null") return "-";

      if (dateStr.length >= 10) {
        String sub = dateStr.substring(0, 10);
        List<String> parts = sub.split('-');
        if (parts.length == 3) {
          return "${parts[2]}/${parts[1]}/${parts[0]}";
        }
        return sub;
      }
      return dateStr;
    } catch (_) {
      return dateInput.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dynamic user = authProvider.user;

    // Variables par défaut
    String fullName = "Utilisateur VSM";
    String email = "Non renseigné";
    String phone = "Non renseigné";
    String position = "Non défini";
    String jerseyNumber = "-";
    String role = "Membre";
    String rawStatus = "actif";
    bool isStarter = false;
    dynamic rawCreatedAt;
    String? photoUrl;

    if (user != null) {
      if (user is Map) {
        fullName =
            user['fullName'] ??
            user['name'] ??
            user['nom'] ??
            "Utilisateur VSM";
        email = user['email'] ?? "Non renseigné";
        phone = user['phone'] ?? user['telephone'] ?? "Non renseigné";
        position = user['position'] ?? "Non défini";
        jerseyNumber = user['jerseyNumber']?.toString() ?? "-";
        role = user['role']?.toString() ?? "Membre";
        rawStatus =
            user['status'] ?? (user['isActive'] == true ? 'actif' : 'inactif');
        isStarter = user['isStarter'] ?? false;

        // Récupération de la date de création depuis la Map
        rawCreatedAt =
            user['created_at'] ??
            user['createdAt'] ??
            user['dateJoined'] ??
            user['created_date'];
        photoUrl = user['photoUrl'] ?? user['avatarUrl'];
      } else {
        try {
          fullName =
              user.fullName ?? user.name ?? user.nom ?? "Utilisateur VSM";
          email = user.email ?? "Non renseigné";
          phone = user.phone ?? "Non renseigné";
          position = user.position ?? "Non défini";
          jerseyNumber = user.jerseyNumber?.toString() ?? "-";
          role = user.role?.toString() ?? "Membre";
          rawStatus =
              user.status ?? (user.isActive == true ? 'actif' : 'inactif');
          isStarter = user.isStarter ?? false;

          // Récupération sécurisée depuis l'objet UserModel (ajuste selon les attributs de ton modèle si besoin)
          rawCreatedAt = user.createdAt ?? user.created_at ?? user.dateJoined;
          photoUrl = user.photoUrl;
        } catch (e) {
          debugPrint("Erreur lecture propriétés objet user : $e");
        }
      }
    }

    // Formatage propre du rôle
    final String cleanRole = role.split('.').last.trim();
    final String formattedRole = cleanRole.isNotEmpty
        ? cleanRole[0].toUpperCase() + cleanRole.substring(1).toLowerCase()
        : "Membre";

    // Formatage précis du statut
    final String cleanStatus = rawStatus
        .toString()
        .split('.')
        .last
        .trim()
        .toLowerCase();
    String formattedStatus = "Actif";
    Color statusColor = Colors.green;

    if (cleanStatus == 'inactif' || cleanStatus == 'inactive') {
      formattedStatus = "Inactif";
      statusColor = Colors.orange;
    } else if (cleanStatus == 'suspendu' || cleanStatus == 'suspended') {
      formattedStatus = "Suspendu";
      statusColor = Colors.red;
    } else {
      formattedStatus = "Actif";
      statusColor = Colors.green;
    }

    // Application du formatage de la date
    final String memberSince = _formatDate(rawCreatedAt);

    const Color greenPrimary = Color(0xFF1E5235);
    const Color vsmBadgeGreen = Color(0xFF006837);
    const Color goldAccent = Color(0xFFFFC107);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFFF8F9FA),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Profil du Membre",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: greenPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: greenPrimary,
                              border: Border.all(color: goldAccent, width: 2.5),
                            ),
                            child: ClipOval(
                              child: _pickedImageBytes != null
                                  ? Image.memory(
                                      _pickedImageBytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : (photoUrl != null && photoUrl.isNotEmpty)
                                  ? Image.network(photoUrl, fit: BoxFit.cover)
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 45,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: greenPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: vsmBadgeGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              formattedRole,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoSection(
                      title: "Coordonnées",
                      children: [
                        _buildInfoTile(Icons.email_outlined, "Email", email),
                        _buildInfoTile(
                          Icons.phone_outlined,
                          "Téléphone",
                          phone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoSection(
                      title: "Informations VSM FC",
                      children: [
                        _buildInfoTile(Icons.sports_soccer, "Poste", position),
                        _buildInfoTile(
                          Icons.confirmation_number_outlined,
                          "N° Maillot",
                          jerseyNumber,
                        ),
                        _buildInfoTile(
                          Icons.star_outline,
                          "Statut terrain",
                          isStarter ? "Titulaire" : "Remplaçant / Membre",
                        ),
                        _buildInfoTile(
                          Icons.calendar_today_outlined,
                          "Membre depuis",
                          memberSince,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoSection(
                      title: "Compte",
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          key: const ValueKey('account_status_row'),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Statut :",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: statusColor.withOpacity(0.4),
                                  ),
                                ),
                                child: Text(
                                  formattedStatus,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E5235),
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            "$label :",
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A1E13),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
