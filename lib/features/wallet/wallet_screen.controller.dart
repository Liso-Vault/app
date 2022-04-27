import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';

class WalletScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WalletScreenController());
  }
}

class WalletScreenController extends GetxController with ConsoleMixin {
  // VARIABLES

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS
}
