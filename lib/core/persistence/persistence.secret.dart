import 'dart:convert';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:liso/core/persistence/mutable_value.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:secrets/secrets.dart';

import '../liso/liso_paths.dart';
import '../utils/globals.dart';

class SecretPersistence extends GetxController with ConsoleMixin {
  // STATIC
  static SecretPersistence get to => Get.find();
  static Box? box;

  // SYNC
  // WALLET JSON
  final wallet = ''.val('wallet');
  final walletPassword = ''.val('wallet-password');
  final walletSignature = ''.val('wallet-signature');
  final walletPrivateKeyHex = ''.val('wallet-private-key-hex');
  final walletAddress = ''.val('wallet-address');
  // CUSTOM SYNC PROVIDER
  final s3Endpoint = ''.val('s3-endpoint');
  final s3AccessKey = ''.val('s3-access-key');
  final s3SecretKey = ''.val('s3-secret-key');
  final s3Bucket = ''.val('s3-bucket');
  final s3Port = ''.val('s3-port');
  final s3Region = ''.val('s3-region');
  final s3SessionToken = ''.val('s3-session-token');
  final s3UseSsl = true.val('s3 use-ssl');
  final s3EnableTrace = false.val('s3-enable-trace');
  // CONFIG
  final configSecrets = ''.val('secrets_config');
  final configApp = ''.val('app_config');
  final configWeb3 = ''.val('web3_config');
  final configLimits = ''.val('limits_config');
  final configUsers = ''.val('users_config');
  final configGeneral = ''.val('general_config');
  final configAppDomains = ''.val('app_domains_config');

  // GETTERS

  // from the first 32 bits of the signature
  Uint8List get cipherKey {
    if (walletSignature.val.isEmpty) {
      throw 'empty wallet signature = null cipher';
    }

    final key = Uint8List.fromList(
      utf8.encode(walletSignature.val).sublist(0, 32),
    );

    return key;
  }

  String get longAddress =>
      walletAddress.val.isEmpty ? 'error' : walletAddress.val;

  String get shortAddress => walletAddress.val.isEmpty
      ? 'error'
      : '${walletAddress.val.substring(0, 11)}...${walletAddress.val.substring(walletAddress.val.length - 11)}';

  // FUNCTIONS
  static Future<void> open() async {
    box = await Hive.openBox(
      kHiveBoxSecretPersistence,
      encryptionCipher: HiveAesCipher(
        base64Decode(Secrets.secretPersistenceKey),
      ),
      path: LisoPaths.hivePath,
    );
  }

  static Future<void> reset() async {
    await box?.clear();
    await box?.deleteFromDisk();
    await open();
  }

  static Future<void> migrate() async {
    final p = Get.find<Persistence>();
    if (p.migratedSecrets.val) return;

    final s = Get.find<SecretPersistence>();

    // wallet
    s.wallet.val = p.wallet.val;
    s.walletPassword.val = p.walletPassword.val;
    s.walletSignature.val = p.walletSignature.val;
    s.walletPrivateKeyHex.val = p.walletPrivateKeyHex.val;
    s.walletAddress.val = p.walletAddress.val;

    // s3
    s.s3Endpoint.val = p.s3Endpoint.val;
    s.s3AccessKey.val = p.s3AccessKey.val;
    s.s3SecretKey.val = p.s3SecretKey.val;
    s.s3Bucket.val = p.s3Bucket.val;
    s.s3Port.val = p.s3Port.val;
    s.s3Region.val = p.s3Region.val;
    s.s3SessionToken.val = p.s3SessionToken.val;
    s.s3UseSsl.val = p.s3UseSsl.val;
    s.s3EnableTrace.val = s.s3EnableTrace.val;

    Console(name: 'SecretPersistence').wtf('migrated');
  }
}
