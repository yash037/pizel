import 'package:flutter/material.dart';
import 'preview_page.dart';
import 'documents_page.dart';
import '../widgets/home_page_widgets.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  void _navigateToCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraPage()),
    );
  }

  void _navigateToImport(BuildContext context) {
    // Later: navigate to ImportPage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import feature coming soon!')),
    );
  }

  void _navigateToDocuments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DocumentsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pizel App'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const HomeHeader(),
                  const SizedBox(height: 40),
                  HomeActionButtons(
                    onCameraPressed: () => _navigateToCamera(context),
                    onImportPressed: () => _navigateToImport(context),
                  ),
                ],
              ),
            ),
          ),
          BottomNavigationButton(
            onPressed: () => _navigateToDocuments(context),
          ),
        ],
      ),
    );
  }
}
