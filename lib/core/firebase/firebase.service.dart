import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';

class FirebaseService extends GetxService with ConsoleMixin {
  static FirebaseService get to => Get.find();

  // VARIABLES

  // GETTERS

  // INIT
  @override
  void onInit() async {
    console.info('onInit');
    super.onInit();
  }

  // FUNCTIONS
}
