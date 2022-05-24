import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/wallet/wallet.service.dart';

class CreatePasswordScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreatePasswordScreenController(), fenix: true);
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

    await WalletService.to.initPrivateKeyHex(
      privateKeyHex,
      password: passwordController.text,
    );

    // save to persistence
    Persistence.to.wallet.val = WalletService.to.wallet!.toJson();
    // just to make sure the Wallet is ready before proceeding
    await Future.delayed(200.milliseconds);

    // save password to biometric storage
    Persistence.to.walletPassword.val = passwordController.text;
    // save seed to biometric storage
    Persistence.to.mnemonicSeedPhrase.val = Get.parameters['seed']!;

    // open Hive Boxes
    await HiveManager.open();
    change(null, status: RxStatus.success());
    Get.offAllNamed(Routes.configuration);
  }
}
