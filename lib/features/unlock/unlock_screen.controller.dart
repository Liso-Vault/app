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
  final canPop = gParameters['mode'] == 'poppable';
  final reason = gParameters['reason'];

  // PROPERTIES
  int attemptsLeft = Persistence.to.maxUnlockAttempts.val;
  final canProceed = false.obs;
  final obscurePassword = true.obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    // AuthenticationMiddleware.signedIn = false;
    change(GetStatus.success(null));
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
      subTitle: reason ?? 'unlock_your_vault'.tr,
      body: 'authenticate_to_verify_and_approve_this_action'.tr,
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
    if (status == GetStatus.loading()) return console.error('still busy');
    // await UIUtils.showConsent();
    await Get.closeCurrentSnackbar();
    change(GetStatus.loading());
    final password = passwordController.text.trim();

    if (password != SecretPersistence.to.walletPassword.val) {
      return _wrongPassword();
    }

    change(GetStatus.success(null));
    return Get.backLegacy(result: true);
  }

  void _wrongPassword() async {
    change(GetStatus.success(null));
    passwordController.clear();
    canProceed.value = false;
    String message = 'please_enter_your_master_password'.tr;

    if (!canPop) {
      attemptsLeft--;

      if (attemptsLeft <= 0) {
        await LisoManager.reset();
        return Get.offNamedUntil(Routes.main, (route) => false);
      }

      if (attemptsLeft < 3) {
        message =
            '$attemptsLeft ${'attempts_left'.tr} ${'until_your_vault_resets'.tr}';
      }
    }

    UIUtils.showSnackBar(
      title: 'incorrect_master_password'.tr,
      message: message,
      icon: const Icon(Iconsax.warning_2_outline, color: Colors.red),
      seconds: 4,
    );
  }
}
