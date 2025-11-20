import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker picker = ImagePicker();
  // 1. Use pickMultiImage() for multiple selections
  final List<XFile> pickedFiles = await picker.pickMultiImage();

  if (pickedFiles.isNotEmpty) {
    // 2. Iterate over the picked files
    final List<ImageNode> newImages = pickedFiles.map((xFile) {
      // Convert XFile to dart:io File
      return ImageNode(File(xFile.path));
    }).toList();

    // Assuming _images is a List<ImageNode> in your State
    setState(() {
      _images.addAll(newImages); // Add all new images
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newImages.length} images imported successfully'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  } else {
    // Handle the case where the user cancels the selection
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image selection cancelled'),
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
