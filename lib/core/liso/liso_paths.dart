import 'dart:io';

import 'package:console_mixin/console_mixin.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class LisoPaths {
  static Directory? main;
  static Directory? hive;
  static Directory? temp;

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
      await temp!.create(recursive: true);
    }

    // print paths
    final console = Console(name: 'LisoPaths');
    console.info('main: ${main!.path}');
  }
}
