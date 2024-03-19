import 'package:app_core/hive/models/app.hive.dart';
import 'package:app_core/hive/models/device.hive.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/hive/models/app_domain.hive.dart';
import 'package:liso/core/hive/models/category.hive.dart';
import 'package:liso/core/hive/models/group.hive.dart';
import 'package:liso/features/groups/groups.service.dart';

import '../../features/categories/categories.service.dart';
import '../../features/items/items.service.dart';
import '../liso/liso_paths.dart';
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
    // APP DOMAIN
    Hive.registerAdapter(HiveAppDomainAdapter());
    // Hive.registerAdapter(HiveDomainAdapter());
    // METADATA
    Hive.registerAdapter(HiveMetadataAdapter());
    Hive.registerAdapter(HiveMetadataAppAdapter());
    Hive.registerAdapter(HiveMetadataDeviceAdapter());
    // GROUPS
    Hive.registerAdapter(HiveLisoGroupAdapter());
    // CATEGORIES
    Hive.registerAdapter(HiveLisoCategoryAdapter());

    Console(name: 'HiveService').info("init");
  }

  Future<void> open() async {
    await ItemsService.to.open();
    await GroupsService.to.open();
    await CategoriesService.to.open();
    // console.info('open');
  }

  Future<void> purge() async {
    await ItemsService.to.box?.clear();
    await GroupsService.to.box?.clear();
    await CategoriesService.to.box?.clear();
    // console.info('purge');
  }

  Future<void> clear() async {
    await ItemsService.to.clear();
    await GroupsService.to.clear();
    await CategoriesService.to.clear();
    // console.info('clear');
  }

  Future<void> close() async {
    await ItemsService.to.close();
    await GroupsService.to.close();
    await CategoriesService.to.close();
    // console.info('open');
  }
}
