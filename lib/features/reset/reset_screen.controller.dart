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

class ResetScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static ResetScreenController get to => Get.find();

  // VARIABLES

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  void reset() async {
    change(null, status: RxStatus.loading());
    await LisoManager.reset();
    change(null, status: RxStatus.success());
    Get.offNamedUntil(Routes.main, (route) => false);
  }
}
