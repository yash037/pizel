import 'dart:io';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:pizel/pages/documents_page.dart';
import '../utils/image_utils.dart';
import '../utils/image_node.dart';
import '../widgets/editPage/edit_page_widgets.dart';
import 'package:image/image.dart' as img;

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

  void _handleRetake() async {
    final File? newImage = await ImageUtils.captureImage();
    if (newImage != null) {
      setState(() {
        final currentNode = editedImages.elementAt(currentIndex);
        currentNode.file = newImage;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image replaced successfully')),
      );
    }
  }

  void _applyFilter(String filterName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$filterName filter applied (demo)')),
    );
  }

  void _handleRotate() async {
    final currentNode = editedImages.elementAt(currentIndex);
    final file = currentNode.file;

    // Decode the file into an img.Image
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) return;

    // Rotate 90 degrees clockwise
    final rotated = img.copyRotate(decoded, angle: 90);

    // Create a NEW file with a different path
    final directory = file.parent;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final rotatedFile = File('${directory.path}/rotated_$timestamp.jpg')
      ..writeAsBytesSync(img.encodeJpg(rotated));

    // Delete old file if needed (optional)
    // await file.delete();

    // Update the linked list node with new file
    setState(() {
      currentNode.file = rotatedFile;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image rotated successfully')),
      );
    }
  }



  void _doneEditing() async {
    final pdf = pw.Document();

    for (var node in editedImages) {
      final image = pw.MemoryImage(await node.file.readAsBytes());
      pdf.addPage(pw.Page(build: (context) => pw.Center(child: pw.Image(image))));
    }

    final outputDir = await getApplicationDocumentsDirectory();
    final fileName = 'Doc_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${outputDir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved: $fileName')),
    );

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
      appBar: EditPageAppBar(
        onBack: () => Navigator.pop(context),
        onDone: _doneEditing,
        title: 'New Doc ${DateTime.now().toString().substring(0, 16)}',
      ),
      body: Column(
        children: [
          Expanded(
            child: ImageViewer(
              image: image,
              showPrevious: currentIndex > 0,
              showNext: currentIndex < editedImages.length - 1,
              onPrevious: _previousImage,
              onNext: _nextImage,
            ),
          ),
          EditToolbar(
            onRetake: _handleRetake,
            onAdd: _addNewImage,
            onMagicColor: () => _applyFilter('Magic Color'),
            onLighten: () => _applyFilter('Lighten'),
            onGrayscale: () => _applyFilter('Grayscale'),
            onCrop: _cropImage,
            onRotate: () => _handleRotate(),
          ),
        ],
      ),
    );
  }
}