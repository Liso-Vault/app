import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/isolates.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/app/routes.dart';

import '../../core/hive/hive.manager.dart';
import '../../core/utils/biometric.util.dart';

class UnlockScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UnlockScreenController());
  }
}

class UnlockScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final passwordController = TextEditingController();
  final passwordMode = Get.parameters['mode'] == 'password_prompt';

  // PROPERTIES
  final attemptsLeft = PersistenceService.to.maxUnlockAttempts.val.obs;
  final canProceed = false.obs;
  final obscurePassword = true.obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  @override
  void onReady() async {
    authenticateBiometrics();
    super.onReady();
  }

  // FUNCTIONS
  void onChanged(String text) => canProceed.value = text.isNotEmpty;

  // biometric storage
  void authenticateBiometrics() async {
    if (!GetPlatform.isMobile) return; // mobile only
    if (!await BiometricUtils.canAuthenticate()) return;
    final biometricPassword = await BiometricUtils.getPassword();
    if (biometricPassword == null) return;
    // set the password then programmatically unlock
    passwordController.text = biometricPassword;
    // delay to show that password has been inserted
    await Future.delayed(100.milliseconds);
    unlock();
  }

  void unlock() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    change(null, status: RxStatus.loading());

    try {
      Globals.wallet = await compute(Isolates.loadWallet, {
        'file_path': LisoManager.walletFilePath,
        'password': passwordController.text,
      });
    } catch (e) {
      console.error('load wallet failed: ${e.toString()}');
      change(null, status: RxStatus.success());

      passwordController.clear();
      canProceed.value = false;

      if (!passwordMode) {
        attemptsLeft.value--;

        if (attemptsLeft() <= 0) {
          await LisoManager.reset();
          return Get.offNamedUntil(Routes.main, (route) => false);
        }
      }

      UIUtils.showSnackBar(
        title: 'Incorrect password',
        message: 'Please enter your vault password',
        icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
        seconds: 4,
      );

      return;
    }

    if (passwordMode) return Get.back(result: true);

    if (!passwordMode) {
      // open Hive Boxes
      await HiveManager.openBoxes();
      change(null, status: RxStatus.success());
      return Get.offNamedUntil(Routes.main, (route) => false);
    }
  }
}
