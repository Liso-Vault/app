import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/app/routes.dart';

class MnemonicScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MnemonicScreenController());
  }
}

class MnemonicScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES

  // PROPERTIES
  final chkBackedUpSeed = false.obs;
  final chkWrittenSeed = false.obs;

  // GETTERS
  bool get canProceed => chkBackedUpSeed() && chkWrittenSeed();

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

  void continuePressed() {
    Get.offNamedUntil(Routes.main, (route) => false);
  }
}
