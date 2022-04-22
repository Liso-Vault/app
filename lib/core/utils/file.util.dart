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

  static Future<File> move(File file, String path) async {
    try {
      // prefer using rename as it is probably faster
      return await file.rename(path);
    } on FileSystemException catch (_) {
      // if rename fails, copy the source file and then delete it
      final newFile = await file.copy(path);
      await file.delete();
      return newFile;
    }
  }
}
