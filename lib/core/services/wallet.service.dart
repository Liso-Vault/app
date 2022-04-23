import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:liso/core/utils/console.dart';
import 'package:path/path.dart';
import 'package:web3dart/web3dart.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;

import '../liso/liso.manager.dart';
import '../utils/globals.dart';

class WalletService extends GetxService with ConsoleMixin {
  static WalletService get to => Get.find();

  String get address => Globals.wallet?.privateKey.address.hexEip55 ?? '';
  String get shortAddress =>
      address.substring(0, 7) + '...' + address.substring(address.length - 6);

  String get fileName => 'wallet.$kWalletExtension';

  String get filePath => join(
        LisoManager.mainPath,
        fileName,
      );

  bool get fileExists => File(filePath).existsSync();

  Wallet mnemonicToWallet(
    String mnemonic, {
    required String password,
    int index = 0,
  }) {
    final privateKey = mnemonicToPrivateKey(mnemonic, index: index);
    return Wallet.createNew(privateKey, password, Random.secure());
  }

  Wallet privateKeyHexToWallet(
    String privateKeyHex, {
    required String password,
  }) {
    final privateKey = EthPrivateKey.fromHex(privateKeyHex);
    return Wallet.createNew(privateKey, password, Random.secure());
  }

  EthPrivateKey mnemonicToPrivateKey(String mnemonic, {int index = 0}) {
    final privateKeyHex = mnemonicToPrivateKeyHex(mnemonic, index: index);
    return EthPrivateKey.fromHex(privateKeyHex);
  }

  String mnemonicToPrivateKeyHex(String mnemonic, {int index = 0}) {
    final seedHex = bip39.mnemonicToSeedHex(mnemonic);
    final seed = Uint8List.fromList(HEX.decode(seedHex));
    final root = bip32.BIP32.fromSeed(seed);
    final path = root.derivePath("m/44'/60'/0'/0/$index");
    return HEX.encode(path.privateKey!);
  }
}
