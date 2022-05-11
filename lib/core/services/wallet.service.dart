import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:console_mixin/console_mixin.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:web3dart/web3dart.dart';

import '../utils/globals.dart';

class WalletService extends GetxService with ConsoleMixin {
  static WalletService get to => Get.find();

  String get address => Globals.wallet?.privateKey.address.hexEip55 ?? '';
  String get shortAddress =>
      address.substring(0, 13) + '...' + address.substring(address.length - 13);

  bool get exists => PersistenceService.to.wallet.val.isNotEmpty;

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

  void sign(String message) async {
    final messageBytes = Uint8List.fromList(utf8.encode(message));

    final privateKey = Globals.wallet!.privateKey;
    final privateKeyHex = HEX.encode(privateKey.privateKey);

    final signedMessage = await privateKey.sign(messageBytes);
    final signedMessageHex = HEX.encode(signedMessage);

    final signature = EthSigUtil.signMessage(
      privateKey: privateKeyHex,
      message: messageBytes,
    );

    final recoveredAddress = EthSigUtil.ecRecover(
      signature: signature,
      message: messageBytes,
    );

    console.info('message: $message');
    console.info('signature: $signature');
    console.info('recoveredAddress: $recoveredAddress');
    console.wtf('signedMessageHex: $signedMessageHex');
  }
}
