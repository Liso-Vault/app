import 'package:get/get.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/notifications/notifications.manager.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:liso/features/app/routes.dart';

class ResetScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ResetScreenController(), fenix: true);
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
    final unlocked = await Get.toNamed(
          Routes.unlock,
          parameters: {'mode': 'password_prompt', 'biometrics': 'false'},
        ) ??
        false;

    if (!unlocked) return;

    change(null, status: RxStatus.loading());
    await LisoManager.reset();
    change(null, status: RxStatus.success());

    NotificationsManager.notify(
      title: 'Successfully Reset Vault',
      body: 'Your local vault file has successfully been deleted',
    );

    Get.offNamedUntil(Routes.main, (route) => false);
  }
}
