import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bip39/bip39.dart' as bip39;
import 'package:liso/core/hive/models/seed.hive.dart';
import 'package:liso/core/liso/liso_crypter.model.dart';
import 'package:liso/core/liso/liso_vault.model.dart';
import 'package:liso/core/utils/console.dart';
import 'package:web3dart/credentials.dart';

class Isolates {
  static final console = Console(name: 'Isolates');

  static Future<Wallet> loadWallet(Map<String, dynamic> params) async {
    final file = File(params['file_path']);
    final password = params['password'];

    return Wallet.fromJson(
      await file.readAsString(),
      password,
    );
  }

  static Future<List<VaultSeed>> seedsToWallets(
      Map<String, dynamic> params) async {
    final _encryptionKey = params['encryptionKey'] as List<int>;
    final seedsJson = jsonDecode(params['seeds']);

    final seeds = List<HiveSeed>.from(
      seedsJson.map((x) => HiveSeed.fromJson(x)),
    );

    // Convert seeds to Wallet objects
    return seeds.map<VaultSeed>((e) {
      final seedHex = bip39.mnemonicToSeedHex(e.mnemonic);

      final wallet = Wallet.createNew(
        EthPrivateKey.fromHex(seedHex),
        utf8.decode(_encryptionKey), // 32 byte master seed hex as the password
        Random.secure(),
      );

      return VaultSeed(seed: e, wallet: wallet);
    }).toList();
  }

  static Future<String> lisoVaultToJsonEncrypted(
      Map<String, dynamic> params) async {
    final _encryptionKey = params['encryptionKey'] as List<int>;
    final vaultJson = jsonDecode(params['vault']);

    final crypter = LisoCrypter();
    await crypter.initSecretKey(_encryptionKey);

    final vault = LisoVault.fromJson(vaultJson, utf8.decode(_encryptionKey));

    return vault.toJsonStringEncrypted();
  }

  static Future<void> writeStringToFile(Map<String, String> params) async {
    final filePath = params['file_path'] as String;
    final contents = params['contents'] as String;

    try {
      await File(filePath).writeAsString(contents);
    } catch (e) {
      console.info('wallet failed: ${e.toString()}');
      return;
    }
  }

  static String iJsonEncode(dynamic params) {
    return jsonEncode(params);
  }
}
