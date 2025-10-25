import 'package:flutter/material.dart';

/// Homepage hesder
class HomeHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const HomeHeader({
    super.key,
    this.title = 'Welcome to Pizel App',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Camera & Import Button
class HomeActionButtons extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onImportPressed;

  const HomeActionButtons({
    super.key,
    required this.onCameraPressed,
    required this.onImportPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrimaryActionButton(
          onPressed: onCameraPressed,
          icon: Icons.camera_alt,
          label: 'Open Camera',
        ),
        const SizedBox(height: 20),
        PrimaryActionButton(
          onPressed: onImportPressed,
          icon: Icons.file_upload,
          label: 'Import Files',
        ),
      ],
    );
  }
}

/// reuse them
class PrimaryActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PrimaryActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(200, 48),
      ),
    );
  }
}

/// see downloads
class BottomNavigationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color? color;

  const BottomNavigationButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.folder,
    this.label = 'See Documents',
    this.color = Colors.deepPurple,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}