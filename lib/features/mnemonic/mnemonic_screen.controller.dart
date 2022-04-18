import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';

import '../menu/menu.item.dart';

class MnemonicScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MnemonicScreenController());
  }
}

class MnemonicScreenController extends GetxController with ConsoleMixin {
  // VARIABLES'
  List<ContextMenuItem> get menuItems => [
        ContextMenuItem(
          title: 'Copy Mnemonic Phrase',
          leading: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
          onSelected: () => Utils.copyToClipboard(mnemonic()),
        )
      ];

  // PROPERTIES
  final mnemonic = ''.obs;
  final chkBackedUpSeed = false.obs;
  final chkWrittenSeed = false.obs;
  final passphraseIndexedStack = 0.obs;

  // GETTERS
  bool get canProceed => chkBackedUpSeed() && chkWrittenSeed();

  // INIT
  @override
  void onInit() {
    mnemonic.value = bip39.generateMnemonic();
    super.onInit();
  }

  // FUNCTIONS

  void continuePressed() async {
    Get.toNamed(
      Routes.confirmMnemonic,
      parameters: {'mnemonic': mnemonic()},
    );
  }

  void generate() {
    mnemonic.value = bip39.generateMnemonic();
  }
}
