import 'package:flutter/material.dart';

class CameraActionBar extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onImport;
  final VoidCallback onEdit;

  const CameraActionBar({
    super.key,
    required this.onCapture,
    required this.onImport,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ActionButton(
              onPressed: onCapture,
              icon: Icons.camera_alt,
              label: 'Capture',
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ActionButton(
              onPressed: onImport,
              icon: Icons.file_upload,
              label: 'Import',
              color: Colors.orangeAccent,
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onEdit,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(14),
              elevation: 2,
            ),
            child: const Icon(Icons.arrow_forward, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color? backgroundColor;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor, required MaterialAccentColor color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}