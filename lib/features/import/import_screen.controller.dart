import 'dart:convert';
import 'dart:io';

import 'package:bip39/bip39.dart' as bip39;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/hive/models/seed.hive.dart';
import 'package:liso/core/liso/crypter.extensions.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/liso/liso_crypter.model.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/passphrase_card/passphrase.card.dart';
import 'package:liso/features/passphrase_card/passphrase_card.controller.dart';
import 'package:web3dart/credentials.dart';

class ImportScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ImportScreenController());
  }
}

class ImportScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final passphraseCard = const PassphraseCard(mode: PassphraseMode.import);
  final filePathController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

  void continuePressed() async {
    if (!formKey.currentState!.validate()) return;

    final masterSeedPhrase = passphraseCard.obtainMnemonicPhrase();

    if (status == RxStatus.loading()) return console.error('still busy');
    change(null, status: RxStatus.loading());

    final masterSeedHex = bip39.mnemonicToSeedHex(masterSeedPhrase!);
    final masterPassword = masterSeedHex.substring(0, 32);

    final file = File(filePathController.text);
    final vaultJson = jsonDecode(await file.readAsString());

    Wallet? masterWallet;

    try {
      masterWallet = Wallet.fromJson(
        vaultJson['master'],
        masterPassword,
      );

      console.info('master wallet: ${masterWallet.toJson()}');
    } catch (e) {
      console.error('master wallet: ${e.toString()}');
      change(null, status: RxStatus.success());

      UIUtils.showSnackBar(
        title: 'Incorrect Master Seed',
        message: 'Please enter your master seed for this vault',
        icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
        seconds: 4,
      );

      return;
    }

    // // the encryption key from master's private key
    encryptionKey = utf8.encode(masterPassword);
    // // initialize crypter with encryption key
    final crypter = LisoCrypter();
    await crypter.initSecretKey(encryptionKey!);
    // init Liso Manager
    await LisoManager.init();

    // Convert Wallet objects to Hive objects
    final encryptedSeedsSecretBox = SecretBoxExtension.fromJson(
      vaultJson['seeds'],
    );

    final decryptedSeeds = await LisoCrypter().decrypt(encryptedSeedsSecretBox);
    final seedsJson = jsonDecode(utf8.decode(decryptedSeeds));

    final seeds = List<HiveSeed>.from(
      seedsJson.map((x) => HiveSeed.fromJson(x['seed'])),
    );

    await HiveManager.seeds!.addAll(seeds);

    change(null, status: RxStatus.success());

    Get.toNamed(Routes.createPassword, parameters: {'seedHex': masterSeedHex});
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

    filePathController.text = result.files.single.path!;
  }
}
