import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/models/category.hive.dart';
import 'package:liso/core/utils/globals.dart';

import '../../core/hive/hive_categories.service.dart';

class CategoriesController extends GetxController
    with ConsoleMixin, StateMixin {
  static CategoriesController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final data = <HiveLisoCategory>[].obs;

  // GETTERS
  List<HiveLisoCategory> get combined {
    final reserved = reservedCategories.map(
      (e) => HiveLisoCategory(
        id: e,
        name: e.tr,
        metadata: null,
      ),
    );

    return [...reserved, ...HiveCategoriesService.to.data];
  }

  // INIT
  @override
  void onInit() {
    load();
    super.onInit();
  }

  // FUNCTIONS

  void load() {
    data.value = HiveCategoriesService.to.data;

    change(
      null,
      status: data.isEmpty ? RxStatus.empty() : RxStatus.success(),
    );
  }
}
