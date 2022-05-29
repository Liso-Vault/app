import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/hive_groups.service.dart';
import 'package:liso/core/utils/globals.dart';

import '../../core/hive/models/group.hive.dart';

class VaultsController extends GetxController with ConsoleMixin, StateMixin {
  static VaultsController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final data = <HiveLisoGroup>[].obs;
  final filtered = <HiveLisoGroup>[].obs;

  // PROPERTIES

  // GETTERS

  // INIT
  @override
  void onInit() {
    load();
    super.onInit();
  }

  // FUNCTIONS

  void load() {
    data.value = HiveGroupsService.to.data;

    filtered.value = HiveGroupsService.to.data
        .where((e) => !kReservedVaultIds.contains(e.id))
        .toList();

    change(
      null,
      status: filtered.isEmpty ? RxStatus.empty() : RxStatus.success(),
    );
  }
}
