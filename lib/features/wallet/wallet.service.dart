import 'dart:async';
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
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:liso/core/firebase/analytics.service.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:web3dart/web3dart.dart';
import 'package:worker_manager/worker_manager.dart';

import '../../core/hive/hive.service.dart';
import '../../core/hive/models/item.hive.dart';
import '../../core/hive/models/metadata/metadata.hive.dart';
import '../../core/utils/globals.dart';
import '../categories/categories.controller.dart';
import '../items/items.service.dart';

class WalletService extends GetxService with ConsoleMixin {
  static WalletService get to => Get.find();

  // VARIABLES
  final gecko = CoinGeckoApi();

  // PROPERTIES
  final network = 'Polygon Testnet'.obs;

  // GETTERS
  Wallet? wallet;
  Uint8List? cipherKey;

  bool get isReady => wallet != null;

  Uint8List get privateKey => wallet!.privateKey.privateKey;
  String get privateKeyHex => HEX.encode(privateKey);

  EthereumAddress get address => wallet!.privateKey.address;

  String get longAddress => address.hexEip55;

  String get shortAddress =>
      '${longAddress.substring(0, 11)}...${longAddress.substring(longAddress.length - 11)}';

  bool get isSaved => Persistence.to.wallet.val.isNotEmpty;

  double get totalUsdBalance => maticUsdBalance + lisoUsdBalance;

  double get maticUsdBalance =>
      Persistence.to.lastMaticBalance.val *
      Persistence.to.lastMaticUsdPrice.val;

  double get lisoUsdBalance =>
      Persistence.to.lastLisoBalance.val * Persistence.to.lastLisoUsdPrice.val;

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

    Persistence.to.lastMaticUsdPrice.val = result.data.first.getPriceIn('usd')!;
  }

  Wallet mnemonicToWallet(
    String mnemonic, {
    required String password,
    int index = 0,
  }) {
    final privateKey = mnemonicToPrivateKey(mnemonic, index: index);
    return Wallet.createNew(privateKey, password, Random.secure());
  }

  static Wallet privateKeyHexToWallet(
    String privateKeyHex, {
    required String password,
  }) {
    final privateKey_ = EthPrivateKey.fromHex(privateKeyHex);
    return Wallet.createNew(privateKey_, password, Random.secure());
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

  Future<Uint8List> credentialsToCipherKey(EthPrivateKey privateKey_) async {
    final signature = await sign(
      kCipherKeySignatureMessage,
      privateKey_: privateKey_.privateKey,
    );

    // from the first 32 bits of the signature
    return Uint8List.fromList(utf8.encode(signature).sublist(0, 32));
  }

  Future<String> sign(
    String message, {
    bool personal = true,
    Uint8List? privateKey_,
  }) async {
    final messageBytes = Uint8List.fromList(utf8.encode(message));
    final privateKeyHex = HEX.encode(privateKey_ ?? privateKey);
    // console.info('message: $message');

    final signature = await compute(signMessage, {
      'privateKey': privateKeyHex,
      'message': messageBytes,
    });

    // final recovered = EthSigUtil.recoverSignature(
    //   signature: signature,
    //   message: messageBytes,
    // );

    // console.info('EthSigUtil signature: $signature');
    // console.wtf('EthSigUtil recovered: $recovered');

    final personalSignature = await compute(signPersonalMessage, {
      'privateKey': privateKeyHex,
      'message': messageBytes,
    });

    // final personalRecovered = EthSigUtil.recoverPersonalSignature(
    //   signature: personalSignature,
    //   message: messageBytes,
    // );

    // console.info('EthSigUtil personalSignature: $personalSignature');
    // console.wtf('EthSigUtil personalRecovered: $personalRecovered');

    return personal ? personalSignature : signature;
  }

  Future<Wallet?> initJson(String data, {required String password}) async {
    Wallet? wallet_;

    try {
      await Executor().execute(
        arg1: {'data': data, 'password': password},
        fun1: walletFromJson,
      ).then((value) => wallet_ = value);
    } catch (e) {
      console.error('error: $e');
    }

    return wallet_;
  }

  Future<void> init(Wallet wallet_) async {
    wallet = wallet_;
    // save to persistence
    Persistence.to.walletAddress.val = longAddress;
    Persistence.to.wallet.val = await compute(walletToJsonString, wallet!);

    // generate cipher key
    final signature = await sign(kCipherKeySignatureMessage);
    // from the first 32 bits of the signature
    cipherKey = Uint8List.fromList(utf8.encode(signature).sublist(0, 32));

    if (!GetPlatform.isWindows) {
      AnalyticsService.to.instance.setUserProperty(
        name: 'wallet_address',
        value: longAddress,
      );
    }
  }

  void reset() {
    wallet = null;
    cipherKey = null;
  }

  Future<void> create(String seed, String password, bool isNew) async {
    final wallet_ = mnemonicToWallet(seed, password: password);
    await init(wallet_);
    // just to make sure the Wallet is ready before proceeding
    await Future.delayed(200.milliseconds);
    // save password
    Persistence.to.walletPassword.val = password;
    // open Hive Boxes
    await HiveService.to.open();
    if (!isNew) return;
    // inject values to fields
    final category = CategoriesController.to.combined
        .firstWhere((e) => e.id == LisoItemCategory.cryptoWallet.name);
    var fields = category.fields;

    fields = fields.map((e) {
      if (e.identifier == 'seed') {
        e.data.value = seed;
        e.readOnly = true;
        return e;
      } else if (e.identifier == 'password') {
        e.data.value = password;
        e.readOnly = true;
        return e;
      } else if (e.identifier == 'private_key') {
        e.data.value = privateKeyHex;
        e.readOnly = true;
        return e;
      } else if (e.identifier == 'address') {
        e.data.value = longAddress;
        e.readOnly = true;
        return e;
      } else if (e.identifier == 'note') {
        e.data.value =
            'It is recommended you have a written copy of your master seed phrase on some physical object and store it safely. You are free to delete this item.';
        return e;
      } else {
        return e;
      }
    }).toList();

    // save cipher key as a liso item
    await ItemsService.to.box!.add(HiveLisoItem(
      identifier: 'seed',
      groupId: 'secrets', // TODO: use enums for reserved groups
      category: category.id,
      title: 'Liso Master Seed Phrase',
      fields: fields,
      metadata: await HiveMetadata.get(),
      protected: true,
      reserved: true,
      tags: ['secret'],
    ));
  }
}

// ISOLATE FUNCTIONS

Future<Wallet> walletFromJson(Map<String, dynamic> arg, TypeSendPort port) {
  return Future.value(Wallet.fromJson(arg['data'], arg['password']));
}

String walletToJsonString(Wallet arg) {
  return arg.toJson();
}

String signMessage(Map<String, dynamic> arg) {
  return EthSigUtil.signMessage(
    privateKey: arg['privateKey'],
    message: arg['message'],
  );
}

String signPersonalMessage(Map<String, dynamic> arg) {
  return EthSigUtil.signPersonalMessage(
    privateKey: arg['privateKey'],
    message: arg['message'],
  );
}
