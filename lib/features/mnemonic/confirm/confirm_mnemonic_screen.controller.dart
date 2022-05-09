import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/app/routes.dart';

import '../../../core/services/wallet.service.dart';

class ConfirmMnemonicScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConfirmMnemonicScreenController());
  }
}

class ConfirmMnemonicScreenController extends GetxController with ConsoleMixin {
  // VARIABLES
  final seedController = TextEditingController();

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

  void continuePressed() async {
    if (seedController.text.isEmpty) return console.error('invalid mnemonic');

    if (seedController.text != Get.parameters['mnemonic']) {
      UIUtils.showSnackBar(
        title: 'Incorrect Mnemonic Phrase',
        message: "Please re-enter your backed up mnemonic seed phrase",
        icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
        seconds: 4,
      );

      return;
    }

    final privateKeyHex = WalletService.to.mnemonicToPrivateKeyHex(
      seedController.text,
    );

    Get.offAllNamed(
      Routes.createPassword,
      parameters: {
        'privateKeyHex': privateKeyHex,
        'seed': seedController.text,
      },
    );
  }
}
