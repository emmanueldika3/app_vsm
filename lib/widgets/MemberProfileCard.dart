import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/widgets/MemberFullProfileWidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsm_app/provider/auth_provider.dart';

class MemberProfileCard extends StatefulWidget {
  final VoidCallback onViewFullProfile;
  final VoidCallback? onEditPhoto;

  const MemberProfileCard({
    super.key,
    required this.onViewFullProfile,
    this.onEditPhoto,
  });

  @override
  State<MemberProfileCard> createState() => _MemberProfileCardState();
}

class _MemberProfileCardState extends State<MemberProfileCard> {
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

  Future<void> _saveAvatarToPrefs(Uint8List bytes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String base64String = base64Encode(bytes);
      await prefs.setString(_prefAvatarKey, base64String);
    } catch (e) {
      debugPrint("Erreur sauvegarde avatar : $e");
    }
  }

  Future<void> _handlePhotoTap() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _pickedImageBytes = bytes;
        });
        await _saveAvatarToPrefs(bytes);
      }
    } catch (e) {
      debugPrint("Erreur sélection image : $e");
    }

    if (widget.onEditPhoto != null) {
      widget.onEditPhoto!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dynamic user = authProvider.user;

    // Récupération exacte via fullName (UserModel) ou fallback Map
    String memberName = "Utilisateur";
    if (user != null) {
      if (user is Map) {
        memberName =
            user['fullName']?.toString() ??
            user['name']?.toString() ??
            user['nom']?.toString() ??
            "Utilisateur";
      } else {
        try {
          memberName =
              user.fullName?.toString() ??
              user.name?.toString() ??
              user.nom?.toString() ??
              "Utilisateur";
        } catch (_) {}
      }
    }

    // Récupération exacte via role
    String rawRole = "Membre";
    if (user != null) {
      if (user is Map) {
        rawRole = user['role']?.toString() ?? "Membre";
      } else {
        try {
          rawRole = user.role?.toString() ?? "Membre";
        } catch (_) {}
      }
    }

    final String cleanRole = rawRole.split('.').last.trim();
    final String formattedRole = cleanRole.isNotEmpty
        ? cleanRole[0].toUpperCase() + cleanRole.substring(1).toLowerCase()
        : "Membre";

    // Récupération de la photo via photoUrl
    String? serverAvatarUrl;
    if (user != null) {
      if (user is Map) {
        serverAvatarUrl =
            user['photoUrl']?.toString() ?? user['avatarUrl']?.toString();
      } else {
        try {
          serverAvatarUrl = user.photoUrl?.toString();
        } catch (_) {}
      }
    }

    const Color vsmDarkGreen = Color(0xFF1E5235);
    const Color vsmBadgeGreen = Color(0xFF006837);
    const Color vsmGold = Color(0xFFFFC107);
    const Color cardBackground = Color.fromARGB(255, 226, 247, 226);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar éditable avec persistance
          GestureDetector(
            onTap: _handlePhotoTap,
            child: Stack(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: vsmDarkGreen,
                  ),
                  child: ClipOval(
                    child: _pickedImageBytes != null
                        ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                        : (serverAvatarUrl != null &&
                              serverAvatarUrl.isNotEmpty)
                        ? Image.network(serverAvatarUrl, fit: BoxFit.cover)
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 32,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: vsmGold,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 11,
                      color: vsmDarkGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Informations du membre (fullName + role)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  memberName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: vsmDarkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: vsmBadgeGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    formattedRole,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action unique sur le côté (l'icône de l'œil uniquement)
          IconButton(
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
            icon: const Icon(
              Icons.remove_red_eye_outlined,
              size: 22,
              color: vsmBadgeGreen,
            ),
            tooltip: "Voir le profil complet",
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    const MemberFullProfileWidget(),
              );
            },
          ),
        ],
      ),
    );
  }
}
