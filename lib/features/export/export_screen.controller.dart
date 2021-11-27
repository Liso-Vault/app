import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bip39/bip39.dart' as bip39;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/liso/liso_vault.model.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web3dart/web3dart.dart';

class ExportScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExportScreenController());
  }
}

class ExportScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final passwordController = TextEditingController();

  // PROPERTIES
  final attemptsLeft = PersistenceController.to.maxUnlockAttempts.val.obs;
  final canProceed = false.obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

  void onChanged(String text) => canProceed.value = text.isNotEmpty;

  void unlock() async {
    if (HiveManager.seeds!.values.isEmpty) {
      UIUtils.showSnackBar(
        title: 'Export Failed',
        message: "There's nothing to export. Please add your seeds first.",
        icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
        seconds: 4,
      );

      return;
    }

    if (status == RxStatus.loading()) return console.error('still busy');
    change(null, status: RxStatus.loading());

    final directory = await getApplicationSupportDirectory();
    final walletFile = File('${directory.path}/$kVaultFileName');

    // this is just to unlock the local master wallet
    Wallet? masterWallet;

    try {
      masterWallet = Wallet.fromJson(
        await walletFile.readAsString(),
        passwordController.text,
      );
    } catch (e) {
      change(null, status: RxStatus.success());
      console.info('wallet failed: ${e.toString()}');

      attemptsLeft.value--;
      passwordController.clear();
      canProceed.value = false;

      if (attemptsLeft() <= 0) {
        LisoManager.reset();
        Get.offNamedUntil(Routes.main, (route) => false);
        return;
      }

      UIUtils.showSnackBar(
        title: 'Incorrect password',
        message: '${attemptsLeft.value} attempts left until your $kName resets',
        icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
        seconds: 4,
      );

      return console.error('incorrect password');
    }

    // choose directory and export file
    String? exportPath = await FilePicker.platform.getDirectoryPath();

    // user cancelled picker
    if (exportPath == null) {
      change(null, status: RxStatus.success());
      return;
    }

    console.info('export path: $exportPath');

    // Convert seeds to Wallet objects
    final seeds = HiveManager.seeds!.values.map<VaultSeed>((e) {
      final seedHex = bip39.mnemonicToSeedHex(e.mnemonic);

      final wallet = Wallet.createNew(
        EthPrivateKey.fromHex(seedHex),
        utf8.decode(encryptionKey!), // 32 byte master seed hex as the password
        Random.secure(),
      );

      return VaultSeed(seed: e, wallet: wallet);
    }).toList();

    final exportMasterWallet = Wallet.createNew(
      masterWallet.privateKey,
      utf8.decode(encryptionKey!), // 32 byte master seed hex as the password
      Random.secure(),
    );

    // Construct LisoVault object
    final vault = LisoVault(master: exportMasterWallet, seeds: seeds);
    final vaultJsonString = await vault.toJsonStringEncrypted();

    final walletAddress = masterWallet.privateKey.address.hexEip55;
    // TODO: improve vault file name format
    final exportFileName =
        'liso_vault_${walletAddress}_${DateTime.now().millisecondsSinceEpoch}.json';
    final exportFile = File('$exportPath/$exportFileName');

    try {
      await exportFile.writeAsString(vaultJsonString);
    } catch (e) {
      console.info('wallet failed: ${e.toString()}');
      change(null, status: RxStatus.success());

      // TODO: Convert to notification
      UIUtils.showSnackBar(
        title: 'Export Failed',
        message: e.toString(),
        icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
        seconds: 4,
      );

      return;
    }

    // TODO: Send notification

    console.info('exported: ${exportFile.path}');
    change(null, status: RxStatus.success());
    Get.back();
  }
}
