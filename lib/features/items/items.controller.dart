import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/models/item.hive.dart';

class ItemsController extends GetxController with ConsoleMixin, StateMixin {
  static ItemsController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final data = <HiveLisoItem>[].obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    load();
    super.onInit();
  }

  // FUNCTIONS

  void load() {
    //
  }
}
