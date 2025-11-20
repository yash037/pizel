import 'package:flutter/material.dart';

/// Homepage header
class HomeHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const HomeHeader({
    super.key,
    this.title = 'Effortless Smart Scanning.',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    // Get the theme
    final theme = Theme.of(context);

    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 250, 
        ),

        const SizedBox(height: 24),

        // (This is your existing code)
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
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
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Get Started Button
class HomeActionButtons extends StatelessWidget {
  final VoidCallback onGetStartedPressed;

  const HomeActionButtons({
    super.key,
    required this.onGetStartedPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryActionButton(
      onPressed: onGetStartedPressed,
      icon: Icons.rocket_launch,
      label: 'Get Started',
    );
  }
}

/// See documents button
class BottomNavigationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const BottomNavigationButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.folder,
    this.label = 'See Documents',
  });

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: secondaryColor),
        label: Text(
          label,
          style: TextStyle(
            color: secondaryColor, 
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// This widget is already correct and flexible. No changes needed.
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