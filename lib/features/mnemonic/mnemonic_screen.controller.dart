import 'package:bip39/bip39.dart' as bip39;
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';

import '../menu/menu.item.dart';

class MnemonicScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MnemonicScreenController(), fenix: true);
  }
}

class MnemonicScreenController extends GetxController with ConsoleMixin {
  // VARIABLES'
  final formKey = GlobalKey<FormState>();
  final seedController = TextEditingController();

  List<ContextMenuItem> get menuItems => [
        ContextMenuItem(
          title: 'Copy Mnemonic Phrase',
          leading: const Icon(Iconsax.warning_2, color: Colors.red),
          onSelected: () => Utils.copyToClipboard(mnemonic()),
        )
      ];

  // PROPERTIES
  final mnemonic = ''.obs;
  final chkBackedUpSeed = false.obs;
  final chkWrittenSeed = false.obs;
  final passphraseIndexedStack = 0.obs;
  final mode = MnemonicMode.generate.obs;

  // GETTERS
  bool get canProceed => chkBackedUpSeed() && chkWrittenSeed();

  // INIT
  @override
  void onInit() {
    mnemonic.value = bip39.generateMnemonic(strength: 256);
    super.onInit();
  }

  // FUNCTIONS

  void continuePressed() async {
    String seed = mnemonic.value;

    if (mode.value == MnemonicMode.restore) {
      if (!formKey.currentState!.validate()) return;
      seed = seedController.text;
    }

    Get.toNamed(
      Routes.confirmMnemonic,
      parameters: {'mnemonic': seed},
    );
  }

  void generate() {
    mnemonic.value = bip39.generateMnemonic(strength: 256);
  }
}

enum MnemonicMode {
  restore,
  generate,
}
