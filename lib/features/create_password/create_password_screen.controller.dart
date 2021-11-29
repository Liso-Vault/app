import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/liso/liso_crypter.model.dart';
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
  final obscure = true.obs;

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
    obscure.value = false;
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

    final file = File('${LisoPaths.main!.path}/$kLocalMasterWalletFileName');
    await file.writeAsString(masterWallet!.toJson());
    console.info('written: ${file.path}');
    console.info(await file.readAsString());

    encryptionKey = utf8.encode(seedHex.substring(0, 32));
    // initialize crypter with encryption key
    final crypter = LisoCrypter();
    await crypter.initSecretKey(encryptionKey!);
    // init Liso Manager
    await LisoManager.init();

    change(null, status: RxStatus.success());

    NotificationsManager.notify(
      title: 'Welcome to $kAppName',
      body: kAppDescription,
    );

    Get.offNamedUntil(Routes.main, (route) => false);
  }
}
