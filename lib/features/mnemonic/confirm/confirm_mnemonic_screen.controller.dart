import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/passphrase_card/passphrase.card.dart';
import 'package:liso/features/passphrase_card/passphrase_card.controller.dart';

class ConfirmMnemonicScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConfirmMnemonicScreenController());
  }
}

class ConfirmMnemonicScreenController extends GetxController with ConsoleMixin {
  // VARIABLES
  final passphraseCard = const PassphraseCard(mode: PassphraseMode.confirm);

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

  void continuePressed() async {
    final mnemonic = passphraseCard.obtainMnemonicPhrase();
    if (mnemonic == null) return console.error('invalid mnemonic');

    if (mnemonic != Get.parameters['mnemonic']) {
      UIUtils.showSnackBar(
        title: 'Incorrect Mnemonic Phrase',
        message: "Please re-enter your backed up mnemonic seed phrase",
        icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
        seconds: 4,
      );

      return;
    }

    final seedHex = bip39.mnemonicToSeedHex(mnemonic);
    Get.toNamed(Routes.createPassword, parameters: {'seedHex': seedHex});
  }
}
