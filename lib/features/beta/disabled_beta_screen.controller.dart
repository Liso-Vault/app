import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';

class DisabledBetaScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DisabledBetaScreenController(), fenix: true);
  }
}

class DisabledBetaScreenController extends GetxController with ConsoleMixin {
  // VARIABLES

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS
}
