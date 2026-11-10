import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme.dart';

class ProfilePhotoPicker extends StatelessWidget {
  const ProfilePhotoPicker({
    super.key,
    required this.photo,
    required this.onChanged,
    this.size = 112,
    this.label = 'Escolher foto',
  });

  final String photo;
  final ValueChanged<String> onChanged;
  final double size;
  final String label;

  Future<void> _chooseImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tirar foto com a câmera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;

    try {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!context.mounted) return;
      if (bytes.length > 1500000) {
        _showMessage(
          context,
          'A foto ficou muito grande. Escolha outra imagem.',
        );
        return;
      }

      onChanged(base64Encode(bytes));
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, 'Não foi possível acessar a imagem: $error');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (photo.isEmpty) {
      image = Icon(
        Icons.person_outline,
        size: size * 0.43,
        color: AppColors.primary,
      );
    } else {
      try {
        image = Image.memory(
          base64Decode(photo),
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, _, _) => Icon(
            Icons.broken_image_outlined,
            size: size * 0.43,
            color: AppColors.textGray,
          ),
        );
      } on FormatException {
        image = Icon(
          Icons.broken_image_outlined,
          size: size * 0.43,
          color: AppColors.textGray,
        );
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _chooseImage(context),
          child: Stack(
            children: [
              Container(
                width: size,
                height: size,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.softBlueBorder, width: 2),
                ),
                child: Center(child: image),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _chooseImage(context),
          icon: const Icon(Icons.add_a_photo_outlined, size: 16),
          label: Text(label),
        ),
      ],
    );
  }
}

class ProfilePhotoAvatar extends StatelessWidget {
  const ProfilePhotoAvatar({super.key, required this.photo, this.size = 52});

  final String photo;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget image = Icon(
      Icons.person_outline,
      size: size * 0.55,
      color: AppColors.primary,
    );
    if (photo.isNotEmpty) {
      try {
        image = Image.memory(
          base64Decode(photo),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Icon(
            Icons.person_outline,
            size: size * 0.55,
            color: AppColors.primary,
          ),
        );
      } on FormatException {
        // Keep the default avatar for invalid stored image data.
      }
    }
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.softBlue,
        shape: BoxShape.circle,
      ),
      child: Center(child: image),
    );
  }
}
