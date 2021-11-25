import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/app.manager.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/app/routes.dart';

class UnlockScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UnlockScreenController());
  }
}

class UnlockScreenController extends GetxController with ConsoleMixin {
  // VARIABLES
  final passwordController = TextEditingController();

  // PROPERTIES
  final attemptsLeft = PersistenceController.to.maxUnlockAttempts.val.obs;
  final canProceed = false.obs;

  // GETTERS

  // INIT

  // FUNCTIONS

  void onChanged(String text) => canProceed.value = text.isNotEmpty;

  void unlock() async {
    const storage = FlutterSecureStorage();
    final savedPassword = await storage.read(key: kPassword);

    if (passwordController.text != savedPassword) {
      attemptsLeft.value--;
      passwordController.clear();
      canProceed.value = false;

      if (attemptsLeft() <= 0) {
        AppManager.reset();
        Get.offNamedUntil(Routes.main, (route) => false);
        return;
      }

      UIUtils.showSnackBar(
        title: 'Incorrect password',
        message: '${attemptsLeft.value} attempts left until your wallet resets',
        icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
        seconds: 4,
      );

      return console.error('incorrect password');
    }

    Get.back();
  }
}
