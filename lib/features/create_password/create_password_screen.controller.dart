import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';

class CreatePasswordScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreatePasswordScreenController());
  }
}

class CreatePasswordScreenController extends GetxController with ConsoleMixin {
  // VARIABLES
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

  void confirm() async {
    // TODO: improve password validation

    if (passwordController.text != passwordConfirmController.text) {
      UIUtils.showSnackBar(
        title: 'Passwords do not match',
        message: 'Re-enter your passwords',
        icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
        seconds: 4,
      );

      return console.error('Passwords do not match');
    }

    const storage = FlutterSecureStorage();
    storage.write(key: kPassword, value: passwordController.text);

    Get.back();
  }
}
