import 'package:flutter/material.dart';
import 'preview_page.dart';
import 'documents_page.dart';
import '../widgets/homePage/home_page_widgets.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  void _navigateToCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PreviewPage()),
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
                    onGetStartedPressed: () => _navigateToCamera(context),
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