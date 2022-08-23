import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';

import '../categories.controller.dart';

class CategoryPickerScreenController extends GetxController with ConsoleMixin {
  static CategoryPickerScreenController get to => Get.find();

  // VARIABLES
  final data = CategoriesController.to.combined.toList();

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

}
