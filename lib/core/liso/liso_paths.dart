import 'dart:io';

import 'package:liso/core/utils/console.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class LisoPaths {
  static Directory? main;
  static Directory? hive;

  static Future<void> init() async {
    main = await getApplicationSupportDirectory();
    hive = Directory(path.join(main!.path, 'hive'));

    // ensure directories exist
    await main!.create(recursive: true);
    await hive!.create(recursive: true);

    // print paths
    final console = Console(name: 'LisoPaths');
    console.info('main: ${main!.path}');
    console.info('hive: ${hive!.path}');
  }
}
