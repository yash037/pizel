import 'dart:io';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:pizel/pages/documents_page.dart';
import '../utils/image_utils.dart';
import '../models/image_node.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final LinkedList<ImageNode> _images = LinkedList<ImageNode>();

  Future<void> _captureImage() async {
    final File? imageFile = await ImageUtils.captureImage();
    if (imageFile != null) {
      setState(() {
        _images.add(ImageNode(imageFile));
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditPage(images: _images),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Page')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: _captureImage,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Capture Image'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }
}

class EditPage extends StatefulWidget {
  final LinkedList<ImageNode> images;
  const EditPage({super.key, required this.images});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  int currentIndex = 0;
  late LinkedList<ImageNode> editedImages;

  @override
  void initState() {
    super.initState();
    editedImages = widget.images;
  }

  Future<void> _cropImage() async {
    final currentNode = editedImages.elementAt(currentIndex);
    final File? cropped = await ImageUtils.cropImage(currentNode.file);
    if (cropped != null) {
      setState(() {
        currentNode.file = cropped;
      });
    }
  }

  void _nextImage() {
    if (currentIndex < editedImages.length - 1) {
      setState(() => currentIndex++);
    }
  }

  void _previousImage() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
    }
  }

  void _addNewImage() async {
    final File? newImage = await ImageUtils.captureImage();
    if (newImage != null) {
      setState(() {
        editedImages.add(ImageNode(newImage));
        currentIndex = editedImages.length - 1;
      });
    }
  }

  void _applyFilter(String filterName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$filterName filter applied (demo)')),
    );
  }

  void _doneEditing() async {
    final pdf = pw.Document();

    // Add each edited image to the PDF
    for (var node in editedImages) {
      final image = pw.MemoryImage(await node.file.readAsBytes());
      pdf.addPage(pw.Page(build: (context) => pw.Center(child: pw.Image(image))));
    }

    // Save PDF in the device's document directory
    final outputDir = await getApplicationDocumentsDirectory();
    final fileName = 'Doc_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${outputDir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved: $fileName')),
    );

    // Navigate to the DocumentsPage to view saved PDFs
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = editedImages.elementAt(currentIndex).file;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Doc ${DateTime.now().toString().substring(0, 16)}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: _doneEditing,
            child: const Text('Done', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.file(image, fit: BoxFit.contain),
                if (currentIndex > 0)
                  Positioned(
                    left: 10,
                    child: IconButton(
                      onPressed: _previousImage,
                      icon: const Icon(Icons.arrow_left,
                          color: Colors.white, size: 40),
                    ),
                  ),
                if (currentIndex < editedImages.length - 1)
                  Positioned(
                    right: 10,
                    child: IconButton(
                      onPressed: _nextImage,
                      icon: const Icon(Icons.arrow_right,
                          color: Colors.white, size: 40),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom toolbar (filters and actions)
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _toolButton(Icons.camera, 'Retake', _addNewImage),
                  _toolButton(Icons.add, 'Add', _addNewImage),
                  _toolButton(Icons.filter, 'Magic Color',
                      () => _applyFilter('Magic Color')),
                  _toolButton(Icons.brightness_low, 'Lighten',
                      () => _applyFilter('Lighten')),
                  _toolButton(Icons.filter_b_and_w, 'Grayscale',
                      () => _applyFilter('Grayscale')),
                  _toolButton(Icons.crop, 'Crop', _cropImage),
                  _toolButton(Icons.rotate_right, 'Rotate',
                      () => _applyFilter('Rotate (demo)')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolButton(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: Colors.white),
          ),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}