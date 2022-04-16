import 'dart:io';

import 'console.dart';

class FileUtils {
  static final console = Console(name: 'FileUtils');

  static Future<void> delete(String path) async {
    try {
      await File(path).delete();
    } catch (e) {
      console.error('error deleting: $e');
    }
  }
}
