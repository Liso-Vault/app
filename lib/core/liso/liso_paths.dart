import 'dart:io';

import 'package:console_mixin/console_mixin.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class LisoPaths {
  // VARIABLES
  static Directory? main;
  static Directory? hive;
  static Directory? temp;

  // GETTERS
  static String get mainPath => main!.path;
  static String get hivePath => hive!.path;
  static String get tempPath => temp!.path;

  static String get tempVaultFilePath =>
      join(LisoPaths.tempPath, kVaultFileName);

  static Future<void> init() async {
    if (!GetPlatform.isWeb) {
      main = await getApplicationSupportDirectory();
    } else {
      main = Directory('');
    }

    hive = Directory(join(main!.path, 'hive'));
    temp = Directory(join(main!.path, 'temp'));

    // ensure directories exist
    if (!GetPlatform.isWeb) {
      await main!.create(recursive: true);
      await hive!.create(recursive: true);

      // cleanup temp directory on every app start
      if (await temp!.exists()) {
        await temp?.delete(recursive: true);
      }

      // recreate temp directory
      await temp!.create(recursive: true);
    }

    // print paths
    final console = Console(name: 'LisoPaths');
    console.info('main: ${main!.path}');
  }
}
