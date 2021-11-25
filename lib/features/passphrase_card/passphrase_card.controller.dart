import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
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
  final seedController = TextEditingController();

  String seed24 = '', seed12 = '';

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

  void init({final mode = PassphraseMode.create, String phrase = ''}) {
    seedController.text = phrase;

    if (mode == PassphraseMode.create) {
      // generate seed
      generateSeed();
      // show generated seed
      strengthIndexChanged(0);
    } else if (mode == PassphraseMode.confirm) {
      //
    } else if (mode == PassphraseMode.import) {
      //
    } else if (mode == PassphraseMode.none) {
      //
    }
  }

  void strengthIndexChanged(int index) {
    if (index == 0) {
      seedController.text = seed24;
    } else {
      seedController.text = seed12;
    }
  }

  void generateSeed() {
    seed24 = bip39.generateMnemonic(strength: 256);
  }

  void generate12Seed() {
    seedController.text = bip39.generateMnemonic(strength: 128);
  }

  void generate24Seed() {
    seedController.text = bip39.generateMnemonic(strength: 256);
  }

  String? validateSeed(String seedPhrase) {
    if (seedPhrase.isEmpty || !bip39.validateMnemonic(seedPhrase)) {
      return 'Invalid seed phrase';
    } else {
      return null;
    }
  }
}
