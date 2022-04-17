import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/notifications/notifications.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:web3dart/credentials.dart';

import '../../core/liso/liso.manager.dart';
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
    final seedHex = Get.parameters['seedHex'];

    Globals.wallet = Wallet.createNew(
      EthPrivateKey.fromHex(seedHex!),
      passwordController.text,
      Random.secure(),
    );

    // save password to biometric storage
    final storage = await BiometricUtils.getStorage(
      title: "Secure Wallet Password",
    ); // TODO: localize

    try {
      await storage.write(passwordController.text);
    } catch (e) {
      change(null, status: RxStatus.success());
      return console.error('biometric error: $e');
    }

    // write wallet json to file
    final file = File(LisoManager.walletFilePath);
    await file.writeAsString(Globals.wallet!.toJson());
    console.info('wallet written: ${file.path}');

    // set global encryption key
    Globals.encryptionKey = utf8.encode(seedHex.substring(0, 32));
    // open Hive Boxes
    await HiveManager.openBoxes();
    change(null, status: RxStatus.success());

    NotificationsManager.notify(
      title: 'Welcome to $kAppName', // TODO: localize
      body: kAppDescription,
    );

    Get.offNamedUntil(Routes.main, (route) => false);
  }
}
