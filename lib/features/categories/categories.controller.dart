import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/models/category.hive.dart';
import 'package:secrets/secrets.dart';

import 'categories.service.dart';

class CategoriesController extends GetxController
    with ConsoleMixin, StateMixin {
  static CategoriesController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final data = <HiveLisoCategory>[].obs;

  // GETTERS
  List<HiveLisoCategory> get reserved => List<HiveLisoCategory>.from(
        Secrets.categories.map((x) => HiveLisoCategory.fromJson(x)),
      );

  Set<HiveLisoCategory> get combined => {...reserved, ...data};

  Iterable<String> get reservedIds => reserved.map((e) => e.id);

  // INIT
  @override
  void onInit() {
    load();
    super.onInit();
  }

  // FUNCTIONS

  void load() {
    data.value = CategoriesService.to.data;
    change(null, status: data.isEmpty ? RxStatus.empty() : RxStatus.success());
  }
}
