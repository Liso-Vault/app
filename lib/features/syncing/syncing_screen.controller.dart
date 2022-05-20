import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/middlewares/authentication.middleware.dart';

import '../app/routes.dart';
import '../s3/s3.service.dart';

class SyncingScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SyncingScreenController());
  }
}

class SyncingScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  @override
  void onInit() {
    sync();
    super.onInit();
  }

  void sync() async {
    change(null, status: RxStatus.loading());
    final result = await S3Service.to.sync();

    if (result.isLeft) {
      change(null, status: RxStatus.error('Error syncing: ${result.left}'));
    } else {
      change(null, status: RxStatus.success());
      Get.offNamedUntil(Routes.main, (route) => false);
    }
  }

  void cancel() {
    AuthenticationMiddleware.ignoreSync = true;
    Get.offNamedUntil(Routes.main, (route) => false);
  }
}
