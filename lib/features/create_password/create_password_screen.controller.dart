import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/notifications/notifications.manager.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/utils/biometric.util.dart';

class CreatePasswordScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreatePasswordScreenController());
  }
}

class CreatePasswordScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  // PROPERTIES
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

  void generate() {
    final password = Utils.generatePassword();
    passwordController.text = password;
    passwordConfirmController.text = password;
    obscurePassword.value = false;
    obscureConfirmPassword.value = false;
  }

  void confirm() async {
    if (!formKey.currentState!.validate()) return;
    if (status == RxStatus.loading()) return console.error('still busy');
    change(null, status: RxStatus.loading());

    // TODO: improve password validation

    if (passwordController.text != passwordConfirmController.text) {
      change(null, status: RxStatus.success());

      // TODO: localize
      UIUtils.showSnackBar(
        title: 'Passwords do not match',
        message: 'Re-enter your passwords',
        icon: const Icon(Iconsax.warning_2, color: Colors.red),
        seconds: 4,
      );

      return console.error('Passwords do not match');
    }

    // write a local master wallet
    // TODO: use a global variable instead to prevent lost
    final privateKeyHex = Get.parameters['privateKeyHex']!;

    Globals.wallet = WalletService.to.privateKeyHexToWallet(
      privateKeyHex,
      password: passwordController.text,
    );

    await Globals.init();

    // just to make sure the Wallet is ready before proceeding
    await Future.delayed(200.milliseconds);

    // save wallet to persistence
    PersistenceService.to.wallet.val = Globals.wallet!.toJson();
    // save password to biometric storage
    await BiometricUtils.save(
      passwordController.text,
      key: kBiometricPasswordKey,
    );

    final seed = Get.parameters['seed']!;
    await BiometricUtils.save(
      seed,
      key: kBiometricSeedKey,
    );

    // open Hive Boxes
    await HiveManager.openBoxes();
    change(null, status: RxStatus.success());

    NotificationsManager.notify(
      title: 'Welcome to ${ConfigService.to.appName}', // TODO: localize
      body: ConfigService.to.general.app.shortDescription,
    );

    Get.offAllNamed(Routes.configuration);
  }
}
