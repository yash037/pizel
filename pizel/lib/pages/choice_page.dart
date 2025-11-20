import 'package:flutter/material.dart';
import '../widgets/homePage/home_page_widgets.dart';
import './edit_page.dart';
import './automate_page.dart';
import 'dart:collection';
import '../utils/image_node.dart';

class ChoicePage extends StatelessWidget {
  final LinkedList<ImageNode> images;

  const ChoicePage({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    // Get the color scheme from the theme
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // No background color needed, it will use scaffoldBackgroundColor from the theme
      appBar: AppBar(
        // Use the theme's background color
        backgroundColor: colorScheme.primary,
        // Set the icon and text color to be visible on the light background
        foregroundColor: colorScheme.onError,
        elevation: 0, // Keep the shadow off
        centerTitle: true,
        title: const Text('Choose Option'),
        // The leading icon will automatically use the foregroundColor
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Go back
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            // Use the secondary color for the border
            color: colorScheme.secondary, 
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const HomeHeader(
                    title: 'Select how you want to create your PDF',
                  ),
                  const SizedBox(height: 48),

                  // Automate PDF button
                  PrimaryActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AutomatePdfPage(images: images),
                        ),
                      );
                    },
                    icon: Icons.auto_fix_high,
                    label: 'Automate PDF',
                    // Use theme colors
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary, 
                  ),
                  const SizedBox(height: 24),

                  // Manual button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPage(images: images),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Manual'),
                    style: ElevatedButton.styleFrom(
                      // Use theme colors
                      backgroundColor:
                          colorScheme.tertiary, 
                      foregroundColor:
                          colorScheme.onError,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      minimumSize: const Size(200, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}