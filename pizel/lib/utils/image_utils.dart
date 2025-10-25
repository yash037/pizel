import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  /// Capture image from camera
  static Future<File?> captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (image != null) return File(image.path);
    } catch (e) {
      print('Error capturing image: $e');
    }
    return null;
  }

  /// Pick image from gallery
  static Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) return File(image.path);
    } catch (e) {
      print('Error picking image from gallery: $e');
    }
    return null;
  }

  /// Crop an image
  static Future<File?> cropImage(File imageFile) async {
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFF000000),
            toolbarWidgetColor: const Color(0xFFFFFFFF),
            lockAspectRatio: false,
          ),
        ],
      );
      if (cropped != null) return File(cropped.path);
    } catch (e) {
      print('Error cropping image: $e');
    }
    return null;
  }
}
