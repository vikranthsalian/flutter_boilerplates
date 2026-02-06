import 'package:share_plus/share_plus.dart';

/// Centralized share utility using SharePlus.instance (latest API).
/// Keeps plugin usage isolated from UI.
class ShareService {
  ShareService._();

  /// Share plain text
  static Future<void> shareText(
    String text, {
    String? subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
      ),
    );
  }

  /// Share a URL
  static Future<void> shareUrl(
    String url, {
    String? subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        text: url,
        subject: subject,
      ),
    );
  }

  /// Share a single file
  static Future<void> shareFile(
    XFile file, {
    String? text,
    String? subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [file],
        text: text,
        subject: subject,
      ),
    );
  }

  /// Share multiple files
  static Future<void> shareFiles(
    List<XFile> files, {
    String? text,
    String? subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: files,
        text: text,
        subject: subject,
      ),
    );
  }
}
