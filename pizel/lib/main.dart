import 'package:flutter/material.dart';
import 'pages/home_page.dart';

// Add these to your constants file or at the top of your main.dart
const Color kPrimaryDark = Color(0xFF37353E);
const Color kSecondaryBlue = Color(0xFF44444E);
const Color kAccentMint = Color(0xFF715A5A);
const Color kAppBackground = Color(0xFFD3DAD9);

void main() {
  runApp(const MyApp());
}

// main.dart

// (Paste the color constants from above here)
// const Color kPrimaryDark = Color(0xFF333446);
// ...

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pizel App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Set the main app background
        scaffoldBackgroundColor: kAppBackground,
        // Define the full color scheme manually
        colorScheme: const ColorScheme(
          brightness: Brightness.light,

          // Main "action" color (buttons, app bars, icons)
          primary: kPrimaryDark,
          onPrimary: kAppBackground, // Text/icons on top of the primary color

          // Secondary color (less important buttons, filters)
          secondary: kSecondaryBlue,
          onSecondary: kAppBackground, // Text/icons on top of secondary

          // Accent color (for things like the "Import" button)
          tertiary: kAccentMint,
          onTertiary: kPrimaryDark, // Dark text looks best on this light mint

          // Background colors
          background: kAppBackground,
          onBackground: kPrimaryDark, // Main text color
          surface: kAppBackground, // Card backgrounds, popups
          onSurface: kPrimaryDark, // Text on cards

          // Error colors (keep standard)
          error: Colors.red,
          onError: Colors.white,
        ),
        // This will style your "Get Started" and "Done" buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryDark, // Primary color
            foregroundColor: kAppBackground, // Text on button
          ),
        ),
        // This will style your app bars
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryDark,
          foregroundColor: kAppBackground, // Title and icons
        ),
      ),
      home: const MyHomePage(),
    );
  }
}