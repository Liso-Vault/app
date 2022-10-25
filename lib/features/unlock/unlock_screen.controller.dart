import 'dart:async';

import 'package:app_core/globals.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/services/local_auth.service.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/middlewares/authentication.middleware.dart';

import '../../core/hive/hive.service.dart';
import '../../core/persistence/persistence.secret.dart';
import '../../core/utils/utils.dart';
import '../main/main_screen.controller.dart';
import '../wallet/wallet.service.dart';

class UnlockScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final passwordController = TextEditingController();
  final promptMode = Get.parameters['mode'] == 'password_prompt';
  final regularMode = Get.parameters['mode'] == 'regular';
  final reason = Get.parameters['reason'];

  // PROPERTIES
  int attemptsLeft = Persistence.to.maxUnlockAttempts.val;
  final canProceed = false.obs;
  final obscurePassword = true.obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    AuthenticationMiddleware.signedIn = false;
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

    final authenticated = await LocalAuthService.to.authenticate(
      subTitle: reason ?? 'Unlock your vault',
      body: 'Authenticate to verify and approve this action',
    );

    if (!authenticated) {
      return console.warning('local auth failed to authenticate');
    }

    // set the password then programmatically unlock
    passwordController.text = SecretPersistence.to.walletPassword.val;
    // delay to show that password has been inserted
    await Future.delayed(100.milliseconds);
    unlock();
  }

  void unlock() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    await UIUtils.showConsent();
    await Get.closeCurrentSnackbar();
    change(null, status: RxStatus.loading());
    final password = passwordController.text.trim();

    if (password != SecretPersistence.to.walletPassword.val) {
      return _wrongPassword();
    }

    if (!WalletService.to.isReady) {
      WalletService.to
          .initJson(SecretPersistence.to.wallet.val, password: password)
          .then((wallet) {
        if (wallet == null) {
          return UIUtils.showSimpleDialog(
            'Wrong Password',
            'Please report to the developer',
          );
        }

        WalletService.to.init(wallet);
      });
    }

    void done() async {
      await HiveService.to.open();
      change(null, status: RxStatus.success());
      AuthenticationMiddleware.signedIn = true;

      if (!promptMode && !regularMode) {
        Persistence.to.sessionCount.val++;
        console.wtf('session count: ${Persistence.to.sessionCount.val}');
      }

      if (promptMode || regularMode) return Get.back(result: true);
      return MainScreenController.to.navigate();
    }

    // temporary to migrate users prior v0.6.0
    Timer.periodic(1.seconds, (timer) async {
      final ready = SecretPersistence.to.walletSignature.val.isNotEmpty &&
          SecretPersistence.to.walletPrivateKeyHex.val.isNotEmpty;

      if (ready) {
        timer.cancel();
        return done();
      } else {
        console.info('wallet still not saved to persistence');
      }
    });
  }

  void _wrongPassword() async {
    change(null, status: RxStatus.success());
    passwordController.clear();
    canProceed.value = false;
    String message = 'Please enter your master password';

    if (!promptMode) {
      attemptsLeft--;

      if (attemptsLeft <= 0) {
        await LisoManager.reset();
        return MainScreenController.to.navigate();
      }

      if (attemptsLeft < 3) {
        message = '$attemptsLeft ${'attempts_left'.tr} until your vault resets';
      }
    }

    UIUtils.showSnackBar(
      title: 'Incorrect Master Password',
      message: message,
      icon: const Icon(Iconsax.warning_2, color: Colors.red),
      seconds: 4,
    );
  }
}
