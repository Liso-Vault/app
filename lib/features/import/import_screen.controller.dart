import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/passphrase_card/passphrase.card.dart';
import 'package:liso/features/passphrase_card/passphrase_card.controller.dart';

class ImportScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ImportScreenController());
  }
}

class ImportScreenController extends GetxController with ConsoleMixin {
  // VARIABLES

  final passphraseCard = const PassphraseCard(mode: PassphraseMode.import);
  final passwordController = TextEditingController();

  // FUNCTIONS

  void importPhrase() async {
    // final seed = passphraseCard.obtainMnemonicPhrase();

    // if (seed == null) {
    //   UIUtils.showSnackBar(
    //     title: 'Invalid Seed',
    //     message: 'Please make sure your seed is valid',
    //     icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
    //     seconds: 4,
    //   );

    //   return console.info('invalid seed');
    // }

    // console.info('seed: $seed');

    // final keyStore = KeyStore.fromMnemonic(seed);

    // Get.toNamed(
    //   Routes.createPassword,
    //   parameters: {'mnemonic': keyStore.mnemonic!},
    // );
  }

  void importFile() async {
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
    } catch (e) {
      console.error('FilePicker error: $e');
      return;
    }

    if (result == null || result.files.isEmpty) {
      console.warning("canceled file picker");
      return;
    }

    final file = File(result.files.single.path!);

    Get.toNamed(
      Routes.unlockImported,
      parameters: {'file_path': file.path},
    );
  }
}
