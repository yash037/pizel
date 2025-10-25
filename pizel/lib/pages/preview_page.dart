import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:collection';
import 'edit_page.dart';
import '../utils/image_utils.dart';
import '../models/image_node.dart';
import '../widgets/image_grid.dart';
import '../widgets/camer_action_bar.dart';
import '../widgets/empty_state.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final LinkedList<ImageNode> _images = LinkedList<ImageNode>();

  Future<void> _handleCapture() async {
    final File? imageFile = await ImageUtils.captureImage();
    if (imageFile != null) {
      setState(() {
        _images.add(ImageNode(imageFile));
      });
    }
  }

  void _goToEditPage() {
    if (_images.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditPage(images: _images)),
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
            onEdit: _goToEditPage,
          ),
        ],
      ),
    );
  }
}
