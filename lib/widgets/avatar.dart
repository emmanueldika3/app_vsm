import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserAvatar extends StatefulWidget {
  final double radius;
  final String? imageUrl;
  final String initials;
  final bool isEditable;
  final Function(File pickedImage)? onImageSelected;

  const UserAvatar({
    super.key,
    this.radius = 40.0,
    this.imageUrl,
    this.initials = 'VSM',
    this.isEditable = true,
    this.onImageSelected,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  File? _localImage;
  final ImagePicker _picker = ImagePicker();

  // Charte VSM
  static const Color greenPrimary = Color(0xFF1E5235);
  static const Color goldAccent = Color(0xFFD4AF37);

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Ferme la BottomSheet
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _localImage = imageFile;
      });

      if (widget.onImageSelected != null) {
        widget.onImageSelected!(imageFile);
      }
    }
  }

  void _showImagePickerOptions() {
    if (!widget.isEditable) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Modifier la photo de profil',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: greenPrimary),
                  title: const Text('Choisir dans la galerie'),
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: greenPrimary),
                  title: const Text('Prendre une photo'),
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _showImagePickerOptions,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: goldAccent, width: 2.0),
            ),
            child: CircleAvatar(
              radius: widget.radius,
              backgroundColor: greenPrimary,
              backgroundImage: _getAvatarImage(),
              child: _getAvatarContent(),
            ),
          ),
        ),
        if (widget.isEditable)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImagePickerOptions,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: goldAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: widget.radius * 0.4,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  ImageProvider? _getAvatarImage() {
    if (_localImage != null) {
      return FileImage(_localImage!);
    } else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return NetworkImage(widget.imageUrl!);
    }
    return null;
  }

  Widget? _getAvatarContent() {
    if (_localImage == null &&
        (widget.imageUrl == null || widget.imageUrl!.isEmpty)) {
      return Text(
        widget.initials.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: widget.radius * 0.6,
        ),
      );
    }
    return null;
  }
}
