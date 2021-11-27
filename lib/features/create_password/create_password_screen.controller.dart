import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/liso/liso_crypter.model.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:path_provider/path_provider.dart';
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

  // GETTERS

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

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

    final wallet = Wallet.createNew(
      EthPrivateKey.fromHex(seedHex!),
      passwordController.text,
      Random.secure(),
    );

    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/$kLocalMasterWalletFileName');
    await file.writeAsString(wallet.toJson());
    console.info('written: ${file.path}');
    console.info(await file.readAsString());

    encryptionKey = utf8.encode(seedHex.substring(0, 32));
    // initialize crypter with encryption key
    final crypter = LisoCrypter();
    await crypter.initSecretKey(encryptionKey!);
    // init Liso Manager
    await LisoManager.init();

    change(null, status: RxStatus.success());

    Get.offNamedUntil(Routes.main, (route) => false);
  }
}
