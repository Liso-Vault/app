import 'dart:io';

import 'package:console_mixin/console_mixin.dart';

class FileUtils {
  static final console = Console(name: 'FileUtils');

  static Future<void> delete(String path) async {
    final file = File(path);

    if (!await file.exists()) return;

    try {
      await file.delete();
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
