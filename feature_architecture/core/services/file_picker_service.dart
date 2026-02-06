import 'package:file_picker/file_picker.dart';

/// Centralized file picker service.
/// Keeps file_picker usage out of UI widgets.
class FilePickerService {
  FilePickerService._();

  /// Pick a single file (any type)
  static Future<PlatformFile?> pickFile({
    bool allowMultiple = false,
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: allowedExtensions == null ? FileType.any : FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result == null || result.files.isEmpty) return null;
    return result.files.first;
  }

  /// Pick multiple files
  static Future<List<PlatformFile>> pickMultipleFiles({
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: allowedExtensions == null ? FileType.any : FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    return result?.files ?? [];
  }

  /// Pick image files only
  static Future<PlatformFile?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    return result?.files.first;
  }

  /// Pick document files (pdf, doc, docx)
  static Future<PlatformFile?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    return result?.files.first;
  }
}
