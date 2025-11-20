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
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      // ✅ Use theme's primary color (kPrimaryDark)
      backgroundColor: colorScheme.primary,
      leading: IconButton(
        // ✅ Use theme's "on primary" color (kAppBackground)
        icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
        onPressed: onBack,
      ),
      title: Text(
        title,
        style: TextStyle(color: colorScheme.onPrimary, fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: onDone,
          // ✅ Use theme's secondary color (kSecondaryBlue) for accent
          child: Text('Done', style: TextStyle(color: colorScheme.secondary)),
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
    // Get the color scheme for this widget
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        Image.file(image, fit: BoxFit.contain),
        if (showPrevious && onPrevious != null)
          Positioned(
            left: 10,
            child: IconButton(
              onPressed: onPrevious,
              icon: Icon(Icons.arrow_left,
                  color: colorScheme.onPrimary, size: 40), 
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primary.withOpacity(0.5),
              ),
            ),
          ),
        if (showNext && onNext != null)
          Positioned(
            right: 10,
            child: IconButton(
              onPressed: onNext,
              icon: Icon(Icons.arrow_right,
                  color: colorScheme.onPrimary, size: 40), 
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primary.withOpacity(0.5),
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
      color: Theme.of(context).colorScheme.primary, 
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ToolButton(icon: Icons.camera, label: 'Retake', onTap: onRetake),
            ToolButton(icon: Icons.add, label: 'Add', onTap: onAdd),
            ToolButton(
                icon: Icons.filter, label: 'Magic Color', onTap: onMagicColor),
            ToolButton(
                icon: Icons.brightness_low, label: 'Lighten', onTap: onLighten),
            ToolButton(
                icon: Icons.filter_b_and_w,
                label: 'Grayscale',
                onTap: onGrayscale),
            ToolButton(icon: Icons.crop, label: 'Crop', onTap: onCrop),
            ToolButton(
                icon: Icons.rotate_right, label: 'Rotate', onTap: onRotate),
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
    // Get the "on primary" color from the theme
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: onPrimaryColor), 
          ),
          Text(
            label,
            style:
                TextStyle(color: onPrimaryColor, fontSize: 12), 
          ),
        ],
      ),
    );
  }
}