import 'package:image_picker/image_picker.dart';

/// Centralized image picker service.
/// Keeps image_picker usage out of UI widgets.
class ImagePickerService {
  ImagePickerService._();

  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  static Future<XFile?> pickFromGallery({
    int imageQuality = 85,
  }) async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality,
    );
  }

  /// Pick image from camera
  static Future<XFile?> pickFromCamera({
    int imageQuality = 85,
  }) async {
    return _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
    );
  }

  /// Pick multiple images from gallery
  static Future<List<XFile>> pickMultiple({
    int imageQuality = 85,
  }) async {
    return _picker.pickMultiImage(
      imageQuality: imageQuality,
    );
  }
}
