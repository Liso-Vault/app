import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/notifications/notifications.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:web3dart/credentials.dart';

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

      UIUtils.showSnackBar(
        title: 'Passwords do not match',
        message: 'Re-enter your passwords',
        icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
        seconds: 4,
      );

      return console.error('Passwords do not match');
    }

    // write a local master wallet
    final seedHex = Get.parameters['seedHex'];

    masterWallet = Wallet.createNew(
      EthPrivateKey.fromHex(seedHex!),
      passwordController.text,
      Random.secure(),
    );

    // save password to biometric storage
    final passwordStorage = await BiometricStorage().getStorage(
      kBiometricPasswordKey,
    );

    passwordStorage.write(passwordController.text);
    console.info('password storage: ${await passwordStorage.read()}');

    // write wallet json to file
    final file = File('${LisoPaths.main!.path}/$kLocalMasterWalletFileName');
    await file.writeAsString(masterWallet!.toJson());
    console.info('written: ${file.path}');

    // set global encryption key
    encryptionKey = utf8.encode(seedHex.substring(0, 32));
    // open Hive Boxes
    await HiveManager.openBoxes();
    change(null, status: RxStatus.success());

    NotificationsManager.notify(
      title: 'Welcome to $kAppName',
      body: kAppDescription,
    );

    Get.offNamedUntil(Routes.main, (route) => false);
  }
}
