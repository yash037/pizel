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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Choose Option'),
        backgroundColor: Colors.white, // Set to white to match page
        elevation: 0, // Remove shadow
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context), // Go back
        ),
        
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.deepPurple, // Border color
            height: 1, // Border thickness
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
                          builder: (context) => AutomatePdfPage(images: images),
                        ),
                      );
                    },
                    icon: Icons.auto_fix_high,
                    label: 'Automate PDF',
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
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
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
