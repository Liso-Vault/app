import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/hive_groups.service.dart';
import 'package:liso/core/utils/globals.dart';

import '../../core/hive/models/group.hive.dart';

class GroupsController extends GetxController with ConsoleMixin, StateMixin {
  static GroupsController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final data = <HiveLisoGroup>[].obs;

  // GETTERS
  List<HiveLisoGroup> get combined {
    final reserved = reservedVaultIds.map(
      (e) => HiveLisoGroup(
        id: e,
        name: e.tr,
        metadata: null,
      ),
    );

    return [...reserved, ...HiveGroupsService.to.data];
  }

  // INIT
  @override
  void onInit() {
    load();
    super.onInit();
  }

  // FUNCTIONS

  void load() {
    data.value = HiveGroupsService.to.data;

    change(
      null,
      status: data.isEmpty ? RxStatus.empty() : RxStatus.success(),
    );
  }
}
