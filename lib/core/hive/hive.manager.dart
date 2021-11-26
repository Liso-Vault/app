import 'dart:io';

import 'package:hive/hive.dart';
import 'package:liso/core/hive/models/app.hive.dart';
import 'package:liso/core/hive/models/device.hive.dart';
import 'package:liso/core/hive/models/seed.hive.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'models/metadata.hive.dart';

class HiveManager {
  static final console = Console(name: 'HiveManager');

  // VARIABLES
  static Box<HiveSeed>? seeds;

  // GETTERS

  // INIT
  static Future<void> init() async {
    // PATH
    final dir = await getApplicationDocumentsDirectory();
    Hive.init("${dir.path}/hive/");
    // REGISTER ADAPTERS
    Hive.registerAdapter(HiveSeedAdapter());
    Hive.registerAdapter(HiveMetadataAdapter());
    Hive.registerAdapter(HiveAppAdapter());
    Hive.registerAdapter(HiveDeviceAdapter());

    console.info("init");
  }

  static Future<void> fixCorruptedBox() async {
    final dir = await getApplicationDocumentsDirectory();

    // We get the corrupted box file.
    final boxPath = path.join(
      dir.path,
      "${dir.path}/hive/",
      'seeds.hive',
    );

    final boxFile = File(boxPath);

    // We read the corrupted content.
    final corruptedContent = await boxFile.readAsBytes();

    // We remove the null elements symbolyzed by the first sequence of 0 values. (ex: [0, 0, 0, 0, 0, 0, 0, 0, 63, 0, 0, 0, 1, 21, 112, 101, 114, 109, 105, 115, 115, 105, ...])
    final correctedContent = corruptedContent.skipWhile(
      (value) => value == 0,
    );
    // We save the new content in the file
    await boxFile.writeAsBytes(correctedContent.toList());
    // We retry to open the box
    await Hive.openBox<Object>(
      'seeds',
      encryptionCipher: HiveAesCipher(encryptionKey!),
    );
  }
}
