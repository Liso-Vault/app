import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/app/routes.dart';

class ResetScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ResetScreenController());
  }
}

class ResetScreenController extends GetxController with ConsoleMixin {
  static ResetScreenController get to => Get.find();

  // VARIABLES

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

  void reset() {
    LisoManager.reset();
    Get.offNamedUntil(Routes.main, (route) => false);
  }
}
