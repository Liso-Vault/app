import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:coingecko_api/coingecko_api.dart';
import 'package:coingecko_api/coingecko_result.dart';
import 'package:coingecko_api/data/price_info.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:web3dart/web3dart.dart';

import '../../core/utils/globals.dart';

class WalletService extends GetxService with ConsoleMixin {
  static WalletService get to => Get.find();

  // VARIABLES
  final gecko = CoinGeckoApi();

  // PROPERTIES
  final network = 'Polygon Testnet'.obs;

  // GETTERS
  EthereumAddress get address => Globals.wallet!.privateKey.address;

  String get longAddress => address.hexEip55;

  String get shortAddress =>
      '${longAddress.substring(0, 11)}...${longAddress.substring(longAddress.length - 11)}';

  bool get exists => PersistenceService.to.wallet.val.isNotEmpty;

  double get totalUsdBalance => maticUsdBalance + lisoUsdBalance;

  double get maticUsdBalance =>
      PersistenceService.to.lastMaticBalance.val *
      PersistenceService.to.lastMaticUsdPrice.val;

  double get lisoUsdBalance =>
      PersistenceService.to.lastLisoBalance.val *
      PersistenceService.to.lastLisoUsdPrice.val;

  @override
  void onInit() {
    loadPrices();
    super.onInit();
  }

  // FUNCTIONS

  void loadPrices() async {
    CoinGeckoResult<List<PriceInfo>>? result;

    try {
      result = await gecko.simple.listPrices(
        ids: ['matic-network'],
        vsCurrencies: ['usd'],
      );
    } catch (e) {
      return console.error('Gecko Error: ${e.runtimeType}');
    }

    if (result.isError) {
      return console.error(
        'code: ${result.errorCode}, message: ${result.errorMessage}',
      );
    }

    PersistenceService.to.lastMaticUsdPrice.val =
        result.data.first.getPriceIn('usd')!;
  }

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

  Future<String> sign(String message, {bool personal = true}) async {
    final messageBytes = Uint8List.fromList(utf8.encode(message));

    final privateKey = Globals.wallet!.privateKey;
    final privateKeyHex = HEX.encode(privateKey.privateKey);

    // final signedMessage = await privateKey.sign(messageBytes);
    // final signedMessageHex = HEX.encode(signedMessage);

    console.info('message: $message');
    console.warning('privateKeyHex: $privateKeyHex');

    final signature = EthSigUtil.signMessage(
      privateKey: privateKeyHex,
      message: messageBytes,
    );

    final recovered = EthSigUtil.ecRecover(
      signature: signature,
      message: messageBytes,
    );

    console.info('EthSigUtil signature: $signature');
    console.wtf('EthSigUtil recovered: $recovered');

    final personalSignature = EthSigUtil.signPersonalMessage(
      privateKey: privateKeyHex,
      message: messageBytes,
    );

    final personalRecovered = EthSigUtil.ecRecover(
      signature: personalSignature,
      message: messageBytes,
    );

    console.info('EthSigUtil personalSignature: $personalSignature');
    console.wtf('EthSigUtil personalRecovered: $personalRecovered');

    // console.info('signedMessageHex: $signedMessageHex');

    return personal ? personalSignature : signature;
  }
}
