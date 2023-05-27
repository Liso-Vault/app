import 'package:app_core/license/license.service.dart';
import 'package:get/get.dart';

import '../../features/supabase/model/status.model.dart';

class GlobalService extends GetxService {
  static GlobalService get to => Get.find();

  // PROPERTIES
  final userStatus = const Status().obs;

  // GETTERS

  @override
  void onInit() {
    userStatus.listen((status_) {
      LicenseService.to.license.value = status_.license;
    });

    super.onInit();
  }
}
