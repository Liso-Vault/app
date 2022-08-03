import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/app/routes.dart';

import '../../core/hive/hive.service.dart';
import '../../core/services/local_auth.service.dart';
import '../../core/utils/globals.dart';
import '../wallet/wallet.service.dart';

class UnlockScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final passwordController = TextEditingController();
  final passwordMode = Get.parameters['mode'] == 'password_prompt';
  final regularMode = Get.parameters['mode'] == 'regular';

  // PROPERTIES
  int attemptsLeft = Persistence.to.maxUnlockAttempts.val;
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
    authenticate();
    super.onReady();
  }

  // FUNCTIONS
  void onChanged(String text) => canProceed.value = text.isNotEmpty;

  // biometric storage
  void authenticate() async {
    if (!isLocalAuthSupported) return console.warning('local auth unsupported');
    if (!(await LocalAuthService.to.authenticate())) {
      return console.warning('local auth failed to authenticate');
    }

    // set the password then programmatically unlock
    passwordController.text = Persistence.to.walletPassword.val;
    // delay to show that password has been inserted
    await Future.delayed(100.milliseconds);
    unlock();
  }

  void unlock() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    await Get.closeCurrentSnackbar();
    change(null, status: RxStatus.loading());

    final wallet_ = await WalletService.to.initJson(
      Persistence.to.wallet.val,
      password: passwordController.text,
    );

    if (wallet_ == null) {
      change(null, status: RxStatus.success());
      passwordController.clear();
      canProceed.value = false;

      String message = 'Please enter your master password';

      if (!passwordMode) {
        attemptsLeft--;

        if (attemptsLeft <= 0) {
          await LisoManager.reset();
          return Get.offNamedUntil(Routes.main, (route) => false);
        }

        if (attemptsLeft < 3) {
          message =
              '$attemptsLeft ${'attempts_left'.tr} until your vault resets';
        }
      }

      UIUtils.showSnackBar(
        title: 'Incorrect Master Password',
        message: message,
        icon: const Icon(Iconsax.warning_2, color: Colors.red),
        seconds: 4,
      );

      return;
    }

    await WalletService.to.init(wallet_);
    if (passwordMode || regularMode) return Get.back(result: true);
    await HiveService.to.open();
    return Get.offNamedUntil(Routes.main, (route) => false);
  }
}
