import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/features/groups/groups.service.dart';
import 'package:secrets/secrets.dart';

import '../../core/hive/models/group.hive.dart';

class GroupsController extends GetxController with ConsoleMixin, StateMixin {
  static GroupsController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final data = <HiveLisoGroup>[].obs;

  final reserved = List<HiveLisoGroup>.from(
    Secrets.groups.map((x) => HiveLisoGroup.fromJson(x)),
  );

  // GETTERS
  Set<HiveLisoGroup> get combined => {...reserved, ...data};

  Iterable<String> get reservedIds => reserved.map((e) => e.id);

  // INIT
  @override
  void onInit() {
    load();
    super.onInit();
  }

  // FUNCTIONS

  void load() {
    data.value = GroupsService.to.data
        .where(
          (e) => !(e.deleted ?? false),
        )
        .toList();

    change(null, status: data.isEmpty ? RxStatus.empty() : RxStatus.success());
  }
}
