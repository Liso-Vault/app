import 'dart:io';

import 'package:liso/core/utils/console.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class LisoPaths {
  static Directory? main;
  static Directory? hive;
  static Directory? temp;

  static Future<void> init() async {
    main = await getApplicationSupportDirectory();
    hive = Directory(join(main!.path, 'hive'));
    temp = Directory(join(main!.path, 'temp'));

    // ensure directories exist
    await main!.create(recursive: true);
    await hive!.create(recursive: true);
    await temp!.create(recursive: true);

    // print paths
    final console = Console(name: 'LisoPaths');
    console.info('main: ${main!.path}');
  }
}
