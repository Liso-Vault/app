import 'package:biometric_storage/biometric_storage.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/globals.dart';

import '../liso/liso.manager.dart';
import 'console.dart';

class BiometricUtils {
  static final console = Console(name: 'BiometricUtils');
  static bool supported = false;

  static Future<void> init() async {
    if (!GetPlatform.isMobile) return; // fingerprint for mobile only
    supported = await canAuthenticate();
    console.info('init');
  }

  static Future<String?> getPassword() async {
    String? biometricPassword;

    try {
      final storage = await getStorage(kBiometricPasswordKey);
      biometricPassword = await storage.read();
    } catch (e) {
      console.error('biometric storage error: $e');
      return null;
    }

    if (biometricPassword == null) {
      console.warning('no password stored in biometric storage');
      return null;
    }

    return biometricPassword;
  }

  static Future<BiometricStorageFile> getStorage(
    String name, {
    String title = 'Unlock $kAppName',
  }) async {
    const preSubTitle = 'securely access $kAppName via';

    // TODO: localize
    final applePrompt = IosPromptInfo(
      accessTitle: '$preSubTitle KeyChain',
      saveTitle: title,
    );

    // TODO: localize
    final androidPrompt = AndroidPromptInfo(
      title: title,
      subtitle: LisoManager.walletFileName,
      description: '${GetUtils.capitalizeFirst(preSubTitle)} KeyStore',
    );

    final passwordStorage = await BiometricStorage().getStorage(
      name,
      promptInfo: PromptInfo(
        macOsPromptInfo: applePrompt,
        iosPromptInfo: applePrompt,
        androidPromptInfo: androidPrompt,
      ),
    );

    return passwordStorage;
  }

  static Future<bool> canAuthenticate() async {
    final response = await BiometricStorage().canAuthenticate();

    if (response != CanAuthenticateResponse.success) {
      console.warning('biometric authentication not supported: $response');
      return false;
    }

    return true;
  }
}
