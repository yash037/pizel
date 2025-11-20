import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import '../utils/image_node.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;          
import './documents_page.dart';             

class ImageAdjustments {
  double brightness = 0.0;
  double contrast = 1.0;
}

class EditPage extends StatefulWidget {
  final LinkedList<ImageNode> images;

  const EditPage({super.key, required this.images});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  bool _isSaving = false;

  // This method combines your file saving and navigation logic
  Future<void> _saveAndNavigate() async {
    if (widget.images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No images to save')),
      );
      return;
    }

    // Set loading state to disable buttons during saving
    setState(() {
      _isSaving = true;
    });

    try {
      final pdf = pw.Document();

      // Loop through the LinkedList and add each image to the PDF
      for (var imageNode in widget.images) {
        // NOTE: This creates the PDF using the current file path, 
        // including any cropping/rotating applied via image_cropper.
        final image = pw.MemoryImage(await imageNode.file.readAsBytes());
        pdf.addPage(pw.Page(build: (context) => pw.Center(child: pw.Image(image))));
      }

      // Save the PDF file
      final outputDir = await getApplicationDocumentsDirectory();
      final fileName = 'ManualDoc_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${outputDir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved: $fileName')),
        );

        // Navigate to DocumentsPage
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const DocumentsPage(),
          ),
          (Route<dynamic> route) => false, // Clears the stack below DocumentsPage
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  late List<ImageNode> _nodeList;
  
  // FIXED: Map<Key, Value> -> Map<ImageNode, ImageAdjustments>
  final Map<ImageNode, ImageAdjustments> _editStates = {};
  
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _nodeList = widget.images.toList();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_nodeList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Editor")),
        body: const Center(child: Text("No images to edit")),
      );
    }

    final currentNode = _nodeList[_currentIndex];
    final currentAdjustments = _getOrCreateState(currentNode);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Text('Edit Image ${_currentIndex + 1}/${_nodeList.length}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check),
            onPressed: _isSaving ? null : _saveAndNavigate, // Call the new save function
          )
        ],
      ),
      body: Column(
        children: [
          // 1. IMAGE PREVIEW AREA
          Expanded(
            child: Center(
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix(
                  _calculateColorMatrix(currentAdjustments),
                ),
                child: Image.file(
                  currentNode.file,
                  fit: BoxFit.contain,
                  // Key forces refresh if file path changes (after crop)
                  key: ValueKey(currentNode.file.path + currentNode.file.lastModifiedSync().toString()),
                ),
              ),
            ),
          ),

          // 2. PAGE VIEW (Hidden control to swipe)
          SizedBox(
            height: 1,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _nodeList.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (ctx, i) => const SizedBox.shrink(),
            ),
          ),

          // 3. CONTROLS AREA
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.only(bottom: 20, top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brightness Slider
                _buildSliderRow("Brightness", currentAdjustments.brightness, -0.5, 0.5, (val) {
                  setState(() {
                    currentAdjustments.brightness = val;
                  });
                }),
                
                // Contrast Slider
                _buildSliderRow("Contrast", currentAdjustments.contrast, 0.5, 1.5, (val) {
                  setState(() {
                    currentAdjustments.contrast = val;
                  });
                }),
                
                const Divider(),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _currentIndex > 0 
                        ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                        : null,
                      icon: const Icon(Icons.arrow_back_ios),
                    ),

                    ElevatedButton.icon(
                      onPressed: () => _cropImage(currentNode),
                      icon: const Icon(Icons.crop),
                      label: const Text("Crop / Rotate"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),

                    IconButton(
                      onPressed: _currentIndex < _nodeList.length - 1
                        ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                        : null,
                      icon: const Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, double value, double min, double max, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  ImageAdjustments _getOrCreateState(ImageNode node) {
    if (!_editStates.containsKey(node)) {
      _editStates[node] = ImageAdjustments();
    }
    return _editStates[node]!;
  }

  Future<void> _cropImage(ImageNode node) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: node.file.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop & Rotate',
          toolbarColor: Theme.of(context).colorScheme.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop & Rotate',
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        node.file = File(croppedFile.path);
      });
    }
  }

  List<double> _calculateColorMatrix(ImageAdjustments adj) {
    double t = (1.0 - adj.contrast) / 2.0;
    double c = adj.contrast;
    double b = adj.brightness * 255; 

    return [
      c, 0, 0, 0, b,
      0, c, 0, 0, b,
      0, 0, c, 0, b,
      0, 0, 0, 1, 0,
    ];
  }
}