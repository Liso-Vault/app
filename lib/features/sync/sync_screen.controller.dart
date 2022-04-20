import 'package:get/get.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';

import '../app/routes.dart';

class SyncScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SyncScreenController());
  }
}

class SyncScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

  void save() {
    final persistence = Get.find<PersistenceService>();
    persistence.syncConfirmed.val = true;
    console.warning('Get.previousRoute: ${Get.previousRoute}');
    if (Get.previousRoute == Routes.welcome) {
      Get.offNamedUntil(Routes.main, (route) => false);
    } else {
      Get.back();
    }
  }
}
