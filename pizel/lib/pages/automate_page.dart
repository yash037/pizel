import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../utils/image_node.dart';
import 'package:http_parser/http_parser.dart';
import 'package:pdf/widgets.dart' as pw;
import './documents_page.dart';

class AutomatePdfPage extends StatefulWidget {
  final LinkedList<ImageNode> images;

  const AutomatePdfPage({super.key, required this.images});

  @override
  State<AutomatePdfPage> createState() => _AutomatePdfPageState();
}

class _AutomatePdfPageState extends State<AutomatePdfPage> {
  bool _isLoading = false;
  List<File> _processedImages = [];

  Future<void> _sendImagesToServer() async {
    setState(() => _isLoading = true);
    try {

      var request = http.MultipartRequest(
        'POST',
        // Uri.parse('http://10.0.2.2:8000/process-multiple'), // for offline emulator
        Uri.parse('http://127.0.0.1:8000/process-multiple'), // for wireless or basic 
      );

      // Add all images as MultipartFiles
      for (var imageNode in widget.images) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            imageNode.file.path,
            contentType: imageNode.file.path.endsWith('.png')
                ? MediaType('image', 'png')
                : MediaType('image', 'jpeg'),
          ),
        );
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        var jsonResp = json.decode(respStr);
        List processedB64 = jsonResp['processed_images'];

        // Decode base64 images to File (temporary in memory)
        List<File> images = [];
        for (int i = 0; i < processedB64.length; i++) {
          final bytes = base64Decode(processedB64[i]);
          final tempFile = File('${Directory.systemTemp.path}/processed_$i.jpg');
          await tempFile.writeAsBytes(bytes);
          images.add(tempFile);
        }

        setState(() {
          _processedImages = images;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to process images on server')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  void initState() {
    super.initState();
    _sendImagesToServer();
  }

  void onDone() async {
    if (_processedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No processed images to save')),
      );
      return;
    }

    final pdf = pw.Document();

    for (var file in _processedImages) {
      final image = pw.MemoryImage(await file.readAsBytes());
      pdf.addPage(pw.Page(build: (context) => pw.Center(child: pw.Image(image))));
    }

    final outputDir = await getApplicationDocumentsDirectory();
    final fileName = 'Doc_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${outputDir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved: $fileName')),
    );

    // Navigate to DocumentsPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DocumentsPage(),
      ),
    );
  }


  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automate PDF'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _processedImages.isEmpty
                      ? const Center(child: Text('No processed images'))
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _processedImages.length,
                          itemBuilder: (context, index) {
                            return Image.file(
                              _processedImages[index],
                              fit: BoxFit.cover,
                            );
                          },
                        ),
            ),
          ),
          // Footer Done button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
