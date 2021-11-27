import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/hive/models/seed.hive.dart';
import 'package:liso/core/liso/crypter.extensions.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/liso/liso_crypter.model.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web3dart/credentials.dart';

class UnlockImportedScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UnlockImportedScreenController());
  }
}

class UnlockImportedScreenController extends GetxController
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
    if (status == RxStatus.loading()) return console.error('still busy');
    change(null, status: RxStatus.loading());

    final importedVaultFilePath = Get.parameters['file_path'];
    final file = File(importedVaultFilePath!);
    final vaultJson = jsonDecode(await file.readAsString());

    Wallet? masterWallet;

    try {
      masterWallet = Wallet.fromJson(
        vaultJson['master'],
        passwordController.text,
      );

      console.info('master wallet: ${masterWallet.toJson()}');
    } catch (e) {
      console.error('vault failed: ${e.toString()}');
      change(null, status: RxStatus.success());

      passwordController.clear();
      canProceed.value = false;

      UIUtils.showSnackBar(
        title: 'Incorrect password',
        message: 'Please enter your vault password',
        icon: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
        seconds: 4,
      );

      return;
    }

    // the encryption key from master's private key
    final seedHex = HEX.encode(masterWallet.privateKey.privateKey);
    encryptionKey = utf8.encode(seedHex.substring(0, 32));
    // initialize crypter with encryption key
    final crypter = LisoCrypter();
    await crypter.initSecretKey(encryptionKey!);
    // init Liso Manager
    await LisoManager.init();

    // write imported master wallet to disk
    final localVaultFilePath =
        '${(await getApplicationSupportDirectory()).path}/$kVaultFileName';
    await File(localVaultFilePath).writeAsString(masterWallet.toJson());

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
    Get.offNamedUntil(Routes.main, (route) => false);
  }
}
