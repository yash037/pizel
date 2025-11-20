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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
              fontSize: 13.5,
              // ✅ USES kSecondaryBlue (via theme)
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ActionButton(
              onPressed: onImport,
              icon: Icons.file_upload,
              label: 'Import',
              // ✅ USES kAccentMint (via theme)
              backgroundColor: colorScheme.tertiary,
              foregroundColor: colorScheme.onError,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onEdit,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(14),
              elevation: 2,
            ),
            child: const Icon(Icons.arrow_forward, size: 26),
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
  final Color? foregroundColor;
  final double? fontSize;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label, style: TextStyle(fontSize: fontSize),),
      
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}