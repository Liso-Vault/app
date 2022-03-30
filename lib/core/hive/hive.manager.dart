import 'package:get/get_utils/src/platform/platform.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/hive/models/metadata/app.hive.dart';
import 'package:liso/core/hive/models/metadata/device.hive.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/utils/console.dart';

import 'models/field.hive.dart';
import 'models/item.hive.dart';
import 'models/metadata/metadata.hive.dart';

class HiveManager {
  static final console = Console(name: 'HiveManager');

  // VARIABLES
  static Box<HiveLisoItem>? items;
  static Box? tags;

  // GETTERS

  // INIT
  static Future<void> init() async {
    // PATH
    if (!GetPlatform.isWeb) {
      Hive.init(LisoPaths.hive!.path);
    }

    // REGISTER ADAPTERS
    Hive.registerAdapter(HiveLisoItemAdapter());
    Hive.registerAdapter(HiveLisoFieldAdapter());
    Hive.registerAdapter(HiveMetadataAdapter());
    Hive.registerAdapter(HiveMetadataAppAdapter());
    Hive.registerAdapter(HiveMetadataDeviceAdapter());

    console.info("init");
  }
}
