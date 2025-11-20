import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<FileSystemEntity> _pdfFiles = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPdfs();
  }

  Future<void> _loadSavedPdfs() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = Directory(dir.path)
        .listSync()
        .where((file) => file.path.endsWith('.pdf'))
        .toList()
      ..sort((a, b) =>
          b.statSync().modified.compareTo(a.statSync().modified)); // latest first

    setState(() => _pdfFiles = files);
  }

  void _openPdf(File file) async {
    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open PDF: ${result.message}')),
      );
    }
  }

  void _sharePdf(File file) {
    Share.shareXFiles([XFile(file.path)], text: 'Check out this PDF I made!');
  }

  void _deletePdf(File file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Delete PDF?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              // ✅ Now this line is valid and will work
              child: Text('Delete', style: TextStyle(color: colorScheme.error)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await file.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF deleted')),
      );
      _loadSavedPdfs();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the colorScheme here for the build method
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        ),
        title: const Text('My Documents'),
        // ✅ This correctly uses the appBarTheme from main.dart
      ),
      body: _pdfFiles.isEmpty
          ? Center(
              child: Text(
                'No documents found',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.secondary,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _pdfFiles.length,
              itemBuilder: (context, index) {
                final file = File(_pdfFiles[index].path);
                final fileName = file.path.split('/').last;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      Icons.picture_as_pdf,
                      color: colorScheme.error,
                    ),
                    title: Text(fileName),
                    subtitle: Text(
                        'Modified: ${file.statSync().modified.toLocal().toString().substring(0, 16)}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'open') _openPdf(file);
                        if (value == 'share') _sharePdf(file);
                        if (value == 'delete') _deletePdf(file);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'open', child: Text('Open')),
                        const PopupMenuItem(
                            value: 'share', child: Text('Share')),
                        const PopupMenuItem(
                            value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}