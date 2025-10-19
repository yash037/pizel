import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _images = [];

  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });

      // Navigate to edit page after capturing
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
      appBar: AppBar(
        title: const Text('Camera Page'),
      ),
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
  final List<File> images;
  const EditPage({super.key, required this.images});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  List<File> editedImages = [];

  @override
  void initState() {
    super.initState();
    editedImages = widget.images;
  }

  Future<void> _cropImage(int index) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: editedImages[index].path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
          aspectRatioLockEnabled: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
      ],
    );

    if (cropped != null) {
      setState(() {
        editedImages[index] = File(cropped.path);
      });
    }
  }

  void _rotateImage(int index) {
    // Placeholder — implement rotation using image package later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rotate feature coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Images')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: editedImages.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Image.file(editedImages[index]),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _cropImage(index),
                      icon: const Icon(Icons.crop),
                      label: const Text('Crop'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _rotateImage(index),
                      icon: const Icon(Icons.rotate_right),
                      label: const Text('Rotate'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
