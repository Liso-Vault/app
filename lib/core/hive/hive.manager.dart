import 'package:hive/hive.dart';
import 'package:liso/core/hive/models/app.hive.dart';
import 'package:liso/core/hive/models/device.hive.dart';
import 'package:liso/core/hive/models/seed.hive.dart';
import 'package:liso/core/utils/console.dart';
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
}
