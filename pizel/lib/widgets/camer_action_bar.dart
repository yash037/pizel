import 'package:flutter/material.dart';

class CameraActionBar extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onEdit;

  const CameraActionBar({
    super.key,
    required this.onCapture,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ActionButton(
            onPressed: onCapture,
            icon: Icons.camera_alt,
            label: 'Capture Image',
          ),
          ActionButton(
            onPressed: onEdit,
            icon: Icons.edit,
            label: 'Edit Page',
            backgroundColor: Colors.green,
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
    this.backgroundColor,
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
