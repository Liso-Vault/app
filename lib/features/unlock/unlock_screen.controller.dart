import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/liso/liso_crypter.model.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/notifications/notifications.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:web3dart/credentials.dart';

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

  // FUNCTIONS
  void onChanged(String text) => canProceed.value = text.isNotEmpty;

  void unlock() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    change(null, status: RxStatus.loading());

    final masterWalletFilePath =
        '${LisoPaths.main!.path}/$kLocalMasterWalletFileName';
    final file = File(masterWalletFilePath);

    try {
      masterWallet = Wallet.fromJson(
        await file.readAsString(),
        passwordController.text,
      );
    } catch (e) {
      console.error('wallet failed: ${e.toString()}');
      change(null, status: RxStatus.success());

      passwordController.clear();
      canProceed.value = false;
      attemptsLeft.value--;

      if (attemptsLeft() <= 0) {
        LisoManager.reset();
        Get.offNamedUntil(Routes.main, (route) => false);
        return;
      }

      UIUtils.showSnackBar(
        title: 'Incorrect password',
        message: 'Please enter your vault password',
        icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
        seconds: 4,
      );

      return;
    }

    // the encryption key from master's private key
    final seedHex = HEX.encode(masterWallet!.privateKey.privateKey);
    encryptionKey = utf8.encode(seedHex.substring(0, 32));

    final crypter = LisoCrypter();
    await crypter.initSecretKey(encryptionKey!);
    // init Liso Manager
    await LisoManager.init();

    change(null, status: RxStatus.success());
    Get.offNamedUntil(Routes.main, (route) => false);
  }
}
