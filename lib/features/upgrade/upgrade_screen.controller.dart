import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';

class UpgradeScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UpgradeScreenController());
  }
}

class UpgradeScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static UpgradeScreenController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final busy = false.obs;

  // PROPERTIES

  // GETTERS

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  @override
  void change(newState, {RxStatus? status}) {
    busy.value = status?.isLoading ?? false;
    super.change(newState, status: status);
  }

  // FUNCTIONS

}
