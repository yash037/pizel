import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:collection';
import '../widgets/previewPage/image_grid.dart';
import '../widgets/previewPage/camer_action_bar.dart';
import '../widgets/previewPage/empty_state.dart';
import '../utils/image_utils.dart';
import '../utils/image_node.dart';
import '../pages/choice_page.dart'; // Import ChoicePage

class PreviewPage extends StatefulWidget {
  const PreviewPage({super.key});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  final LinkedList<ImageNode> _images = LinkedList<ImageNode>();

  Future<void> _handleCapture() async {
    final File? imageFile = await ImageUtils.captureImage();
    if (imageFile != null) {
      setState(() {
        _images.add(ImageNode(imageFile));
      });
    }
  }

  Future<void> _handleImport() async {
    final File? imageFile = await ImageUtils.pickFromGallery();
    if (imageFile != null) {
      setState(() {
        _images.add(ImageNode(imageFile));
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image imported successfully'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _goToChoicePage() {
    if (_images.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChoicePage(images: _images)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images captured yet')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Images'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _images.isEmpty
                ? const EmptyState(message: 'No photos captured yet')
                : ImageGrid(images: _images),
          ),
          CameraActionBar(
            onCapture: _handleCapture,
            onEdit: _goToChoicePage, // Updated here
            onImport: _handleImport,
          ),
        ],
      ),
    );
  }
}
