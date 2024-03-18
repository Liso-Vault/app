import 'dart:async';

import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/services/local_auth.service.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:liso/core/liso/liso.manager.dart';

import '../../core/persistence/persistence.secret.dart';

class UnlockScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final passwordController = TextEditingController();
  final canPop = Get.parameters['mode'] == 'poppable';
  final reason = Get.parameters['reason'];

  // PROPERTIES
  int attemptsLeft = Persistence.to.maxUnlockAttempts.val;
  final canProceed = false.obs;
  final obscurePassword = true.obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    // AuthenticationMiddleware.signedIn = false;
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
    // await UIUtils.showConsent();
    await Get.closeCurrentSnackbar();
    change(null, status: RxStatus.loading());
    final password = passwordController.text.trim();

    if (password != SecretPersistence.to.walletPassword.val) {
      return _wrongPassword();
    }

    change(null, status: RxStatus.success());
    return Get.back(result: true);
  }

  void _wrongPassword() async {
    change(null, status: RxStatus.success());
    passwordController.clear();
    canProceed.value = false;
    String message = 'Please enter your master password';

    if (!canPop) {
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
      icon: const Icon(Iconsax.warning_2_outline, color: Colors.red),
      seconds: 4,
    );
  }
}
