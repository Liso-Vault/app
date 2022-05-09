import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/notifications/notifications.manager.dart';
import 'package:liso/core/services/wallet.service.dart';
import 'package:console_mixin/console_mixin.dart';
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
    final _password = Utils.generatePassword();
    passwordController.text = _password;
    passwordConfirmController.text = _password;
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
        icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
        seconds: 4,
      );

      return console.error('Passwords do not match');
    }

    // write a local master wallet
    final privateKeyHex = Get.parameters['privateKeyHex'];

    Globals.wallet = WalletService.to.privateKeyHexToWallet(
      privateKeyHex!,
      password: passwordController.text,
    );

    // persist wallet address for pre-syncing logic
    // PersistenceService.to.walletAddress.val =
    //     Globals.wallet!.privateKey.address.hexEip55;

    // write wallet json to file
    final file = File(WalletService.to.filePath);
    await file.writeAsString(Globals.wallet!.toJson());
    console.info('wallet written to: ${file.path}');
    // save password to biometric storage
    await BiometricUtils.save(
      passwordController.text,
      key: kBiometricPasswordKey,
    );

    final seed = Get.parameters['seed'];
    await BiometricUtils.save(
      seed!,
      key: kBiometricSeedKey,
    );

    // open Hive Boxes
    await HiveManager.openBoxes();
    change(null, status: RxStatus.success());

    NotificationsManager.notify(
      title: 'Welcome to ${ConfigService.to.appName}', // TODO: localize
      body: ConfigService.to.general.app.shortDescription,
    );

    Get.offAllNamed(Routes.syncSettings);
  }
}
