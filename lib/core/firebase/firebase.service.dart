import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';

import 'config/config.service.dart';
import 'crashlytics.service.dart';

class FirebaseService extends GetxService with ConsoleMixin {
  static FirebaseService get to => Get.find();

  // VARIABLES

  // GETTERS

  // INIT
  @override
  void onInit() async {
    await Firebase.initializeApp();
    Get.put(CrashlyticsService());
    Get.put(ConfigService());
    console.info('onInit');
    super.onInit();
  }

  // FUNCTIONS
}
