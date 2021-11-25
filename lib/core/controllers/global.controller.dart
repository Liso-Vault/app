import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';

class GlobalController extends GetxController with ConsoleMixin {
  static GlobalController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final darkMode = true.obs;

  // GETTERS

  // FUNCTIONS
}
