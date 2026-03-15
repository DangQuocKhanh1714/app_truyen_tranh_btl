import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Helper dùng để dọn dẹp cache tạm (ảnh, file tạm, ...).
class CacheHelper {
  /// Xóa toàn bộ nội dung trong thư mục tạm.
  static Future<void> clearCache() async {
    try {
      final dir = await getTemporaryDirectory();
      if (await dir.exists()) {
        for (final file in dir.listSync(recursive: true)) {
          try {
            if (file is File) {
              await file.delete();
            } else if (file is Directory) {
              await file.delete(recursive: true);
            }
          } catch (_) {
            // Ignore errors, chỉ cố gắng dọn.
          }
        }
      }
    } catch (_) {
      // Ignore errors
    }
  }
}
