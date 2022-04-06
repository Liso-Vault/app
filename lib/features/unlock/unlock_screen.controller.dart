import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/liso/liso_paths.dart';
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
  final attemptsLeft = PersistenceController.to.maxUnlockAttempts.val.obs;
  final canProceed = false.obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  @override
  void onReady() async {
    biometricAuthentication();
    super.onReady();
  }

  // FUNCTIONS
  void onChanged(String text) => canProceed.value = text.isNotEmpty;

  // biometric storage
  void biometricAuthentication() async {
    if (!await BiometricUtils.canAuthenticate()) return;
    final biometricPassword = await BiometricUtils.getPassword();
    if (biometricPassword == null) return;
    // set the password then programmatically unlock
    passwordController.text = biometricPassword;
    await Future.delayed(100.milliseconds);
    unlock();
  }

  void unlock() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    change(null, status: RxStatus.loading());

    final masterWalletFilePath =
        '${LisoPaths.main!.path}/$kLocalMasterWalletFileName';

    try {
      masterWallet = await compute(Isolates.loadWallet, {
        'file_path': masterWalletFilePath,
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
          Get.offNamedUntil(Routes.main, (route) => false);
          return;
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
      // the encryption key from master's private key
      final seedHex = HEX.encode(masterWallet!.privateKey.privateKey);
      encryptionKey = utf8.encode(seedHex.substring(0, 32));

      // open Hive Boxes
      await HiveManager.openBoxes();

      change(null, status: RxStatus.success());
      Get.offNamedUntil(Routes.main, (route) => false);
    }
  }
}
