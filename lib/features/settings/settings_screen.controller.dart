import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:get/get.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web3dart/web3dart.dart';

class SettingsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsScreenController());
  }
}

class SettingsScreenController extends GetxController with ConsoleMixin {
  // VARIABLES

  // PROPERTIES

  // GETTERS

  // INIT

  // FUNCTIONS

  void export() async {
    // TODO: re enter password

    final entropy = utf8.decode(encryptionKey!);
    final mnemonic = bip39.entropyToMnemonic(entropy);
    final seedHex = bip39.mnemonicToSeedHex(mnemonic);

    final wallet = Wallet.createNew(
      EthPrivateKey.fromHex(seedHex),
      'password',
      Random.secure(),
    );

    console.info(
        '${wallet.privateKey.address.hexEip55} wallet json: ${wallet.toJson()}');

    final directory = await getApplicationSupportDirectory();
    final fileName =
        '${kName.toLowerCase()}_${wallet.privateKey.address.hexEip55}';
    final file = File('${directory.path}/$fileName.json');
    await file.writeAsString(wallet.toJson());
    console.info('written');
  }

  void dump() {
    // TODO: re enter password

    final entropy = utf8.decode(encryptionKey!);
    console.info('entropy: $entropy');
    console.info('mnemonic: ${bip39.entropyToMnemonic(entropy)}');

    // TODO: show a dialog
  }
}
