import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/app.manager.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:path_provider/path_provider.dart';
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

    final vaultFilePath =
        '${(await getApplicationSupportDirectory()).path}/$kVaultFileName';
    final file = File(vaultFilePath);

    Wallet? wallet;

    try {
      wallet = Wallet.fromJson(
        await file.readAsString(),
        passwordController.text,
      );

      console.info('wallet: ${wallet.toJson()}');
    } catch (e) {
      console.error('wallet failed: ${e.toString()}');
      change(null, status: RxStatus.success());

      passwordController.clear();
      canProceed.value = false;
      attemptsLeft.value--;

      if (attemptsLeft() <= 0) {
        AppManager.reset();
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
    final seedHex = HEX.encode(wallet.privateKey.privateKey);
    encryptionKey = utf8.encode(seedHex.substring(0, 32));

    await AppManager.init();

    change(null, status: RxStatus.success());
    Get.offNamedUntil(Routes.main, (route) => false);
  }
}
