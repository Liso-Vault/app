import 'dart:convert';

import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:package_info_plus/package_info_plus.dart';

class WelcomeScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WelcomeScreenController());
  }
}

class WelcomeScreenController extends GetxController with ConsoleMixin {
  // VARIABLES

  // PROPERTIES
  final packageInfo = Rxn<PackageInfo>();

  // GETTERS
  String get appVersion =>
      '${packageInfo()?.version}+${packageInfo()?.buildNumber}';

  // INIT
  @override
  void onInit() async {
    packageInfo.value = await PackageInfo.fromPlatform();
    super.onInit();
  }

  // FUNCTIONS

  void create() async {
    const storage = FlutterSecureStorage();

    // generate mnemonic phrase
    final mnemonic = bip39.generateMnemonic(strength: 128); // TODO: try 256
    final entropy = bip39.mnemonicToEntropy(mnemonic);

    // save encryption
    final encryptionKey = utf8.encode(entropy);

    await storage.write(
      key: kEncryptionKey,
      value: base64.encode(encryptionKey),
    );

    Get.back();
  }
}
