//edit page ui componenets

import 'dart:io';
import 'package:flutter/material.dart';

/// Custom AppBar for edit page
class EditPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback onDone;
  final String title;

  const EditPageAppBar({
    super.key,
    required this.onBack,
    required this.onDone,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBack,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: onDone,
          child: const Text('Done', style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Image viewer with navigation arrows
class ImageViewer extends StatelessWidget {
  final File image;
  final bool showPrevious;
  final bool showNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const ImageViewer({
    super.key,
    required this.image,
    required this.showPrevious,
    required this.showNext,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.file(image, fit: BoxFit.contain),
        if (showPrevious && onPrevious != null)
          Positioned(
            left: 10,
            child: IconButton(
              onPressed: onPrevious,
              icon: const Icon(Icons.arrow_left, color: Colors.white, size: 40),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
        if (showNext && onNext != null)
          Positioned(
            right: 10,
            child: IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_right, color: Colors.white, size: 40),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
      ],
    );
  }
}

/// Bottom toolbar with editing tools
class EditToolbar extends StatelessWidget {
  final VoidCallback onRetake;
  final VoidCallback onAdd;
  final VoidCallback onMagicColor;
  final VoidCallback onLighten;
  final VoidCallback onGrayscale;
  final VoidCallback onCrop;
  final VoidCallback onRotate;

  const EditToolbar({
    super.key,
    required this.onRetake,
    required this.onAdd,
    required this.onMagicColor,
    required this.onLighten,
    required this.onGrayscale,
    required this.onCrop,
    required this.onRotate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ToolButton(icon: Icons.camera, label: 'Retake', onTap: onRetake),
            ToolButton(icon: Icons.add, label: 'Add', onTap: onAdd),
            ToolButton(icon: Icons.filter, label: 'Magic Color', onTap: onMagicColor),
            ToolButton(icon: Icons.brightness_low, label: 'Lighten', onTap: onLighten),
            ToolButton(icon: Icons.filter_b_and_w, label: 'Grayscale', onTap: onGrayscale),
            ToolButton(icon: Icons.crop, label: 'Crop', onTap: onCrop),
            ToolButton(icon: Icons.rotate_right, label: 'Rotate', onTap: onRotate),
          ],
        ),
      ),
    );
  }
}

/// Individual tool button
class ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ToolButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: Colors.white),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}