import 'package:biometric_storage/biometric_storage.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:local_auth/local_auth.dart';

import 'console.dart';

class BiometricUtils {
  static final console = Console(name: 'BiometricUtils');
  static bool supported = false;

  static Future<void> init() async {
    if (!GetPlatform.isMobile) return; // fingerprint for mobile only
    supported = await LocalAuthentication().canCheckBiometrics;
    console.info('init');
  }

  static Future<String?> getPassword() async {
    String? biometricPassword;

    try {
      final storage = await getStorage();
      biometricPassword = await storage.read();
    } catch (e) {
      console.error('biometric storage error: $e');
      return null;
    }

    if (biometricPassword == null) {
      console.warning('no password stored in biometric storage');
      return null;
    }

    console.info('biometric password: $biometricPassword');
    return biometricPassword;
  }

  static Future<BiometricStorageFile> getStorage(
      {String title = 'Unlock $kAppName'}) async {
    const preSubTitle = 'securely store and access your wallet password via';

    // TODO: localize
    final applePrompt = IosPromptInfo(
      accessTitle: '$preSubTitle KeyChain',
      saveTitle: title,
    );

    // TODO: localize
    final androidPrompt = AndroidPromptInfo(
      title: title,
      subtitle: kLocalMasterWalletFileName,
      description: '${GetUtils.capitalizeFirst(preSubTitle)} KeyStore',
    );

    final passwordStorage = await BiometricStorage().getStorage(
      kBiometricPasswordKey,
      promptInfo: PromptInfo(
        macOsPromptInfo: applePrompt,
        iosPromptInfo: applePrompt,
        androidPromptInfo: androidPrompt,
      ),
    );

    return passwordStorage;
  }

  static Future<bool> canAuthenticate() async {
    if (!supported) {
      console.info('biometrics not applicable');
      return false;
    }

    final response = await BiometricStorage().canAuthenticate();

    if (response != CanAuthenticateResponse.success) {
      console.warning('biometric authentication not supported');
      return false;
    }

    return true;
  }
}
