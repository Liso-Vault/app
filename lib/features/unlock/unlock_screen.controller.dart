import 'dart:async';

import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/middlewares/authentication.middleware.dart';
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
    passwordController.text = Persistence.to.walletPassword.val;
    // delay to show that password has been inserted
    await Future.delayed(100.milliseconds);
    unlock();
  }

  void unlock() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    await Get.closeCurrentSnackbar();
    change(null, status: RxStatus.loading());

    if (passwordController.text != Persistence.to.walletPassword.val) {
      return _wrongPassword();
    }

    if (!WalletService.to.isReady) {
      WalletService.to
          .initJson(
        Persistence.to.wallet.val,
        password: passwordController.text,
      )
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

    void _done() async {
      AuthenticationMiddleware.signedIn = true;
      await HiveService.to.open();
      change(null, status: RxStatus.success());
      if (passwordMode || regularMode) return Get.back(result: true);
      return Get.offNamedUntil(Routes.main, (route) => false);
    }

    // temporary to migrate users prior v0.6.0
    Timer.periodic(1.seconds, (timer) async {
      if (Persistence.to.walletSignature.val.isNotEmpty &&
          Persistence.to.walletPrivateKeyHex.val.isNotEmpty) {
        timer.cancel();
        return _done();
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

    if (!passwordMode) {
      attemptsLeft--;

      if (attemptsLeft <= 0) {
        await LisoManager.reset();
        return Get.offNamedUntil(Routes.main, (route) => false);
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
