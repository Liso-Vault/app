import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/hive/hive_groups.service.dart';
import 'package:liso/core/hive/hive_shared_vaults.service.dart';
import 'package:liso/core/hive/models/group.hive.dart';
import 'package:liso/core/hive/models/metadata/app.hive.dart';
import 'package:liso/core/hive/models/metadata/device.hive.dart';
import 'package:liso/core/hive/models/shared_vault.hive.dart';
import '../liso/liso_paths.dart';
import 'hive_items.service.dart';
import 'models/field.hive.dart';
import 'models/item.hive.dart';
import 'models/metadata/metadata.hive.dart';

class HiveService extends GetxService with ConsoleMixin {
  static HiveService get to => Get.find<HiveService>();

  static void init() {
    // PATH
    if (!GetPlatform.isWeb) Hive.init(LisoPaths.hivePath);
    // ITEMS
    Hive.registerAdapter(HiveLisoItemAdapter());
    Hive.registerAdapter(HiveLisoFieldAdapter());
    Hive.registerAdapter(HiveLisoFieldDataAdapter());
    Hive.registerAdapter(HiveLisoFieldChoicesAdapter());
    // METADATA
    Hive.registerAdapter(HiveMetadataAdapter());
    Hive.registerAdapter(HiveMetadataAppAdapter());
    Hive.registerAdapter(HiveMetadataDeviceAdapter());
    // GROUPS
    Hive.registerAdapter(HiveLisoGroupAdapter());
    // SHARED VAULTS
    Hive.registerAdapter(HiveSharedVaultAdapter());

    Console(name: 'HiveService').info("init");
  }

  Future<void> clear() async {
    await HiveItemsService.to.clear();
    await HiveGroupsService.to.clear();
    await HiveSharedVaultsService.to.clear();
    console.info('clear');
  }

  Future<void> open() async {
    await HiveItemsService.to.open();
    await HiveGroupsService.to.open();
    await HiveSharedVaultsService.to.open();
    console.info('open');
  }

  Future<void> close() async {
    await HiveItemsService.to.close();
    await HiveGroupsService.to.close();
    await HiveSharedVaultsService.to.close();
    console.info('open');
  }
}