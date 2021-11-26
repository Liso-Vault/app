import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:liso/core/utils/console.dart';

enum PassphraseMode {
  create,
  confirm,
  import,
  none,
}

class PassphraseCardController extends GetxController with ConsoleMixin {
  // VARIABLES
  final mnemonicController = TextEditingController();

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

  void init({final mode = PassphraseMode.create, String phrase = ''}) {
    mnemonicController.text = phrase;

    if (mode == PassphraseMode.create) {
      generateSeed(strength: 256);
    } else if (mode == PassphraseMode.confirm) {
      //
    } else if (mode == PassphraseMode.import) {
      //
    } else if (mode == PassphraseMode.none) {
      //
    }
  }

  void generateSeed({required int strength}) {
    mnemonicController.text = bip39.generateMnemonic(strength: strength);
  }

  String? validateSeed(String mnemonic) {
    if (mnemonic.isEmpty || !bip39.validateMnemonic(mnemonic)) {
      return 'Invalid seed phrase';
    } else {
      return null;
    }
  }
}
