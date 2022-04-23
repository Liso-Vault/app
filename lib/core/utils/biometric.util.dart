import 'package:biometric_storage/biometric_storage.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:local_auth/local_auth.dart';

import '../liso/liso.manager.dart';
import '../services/wallet.service.dart';
import 'console.dart';

class BiometricUtils {
  static final console = Console(name: 'BiometricUtils');
  static bool touchFaceIdSupported = false;

  static Future<void> init() async {
    if (GetPlatform.isMobile) {
      touchFaceIdSupported = await LocalAuthentication().canCheckBiometrics;
    }

    console.info('init');
  }

  static Future<bool> savePassword(String password) async {
    if (!await canAuthenticate()) return false;

    final storage = await getStorage(
      kBiometricPasswordKey,
      title: 'Secure $kAppName',
    );

    try {
      await storage.write(password);
      return true;
    } catch (e) {
      console.error('biometric storage error: $e');
      return false;
    }
  }

  static Future<String?> getPassword() async {
    if (!await canAuthenticate()) return null;
    final storage = await getStorage(kBiometricPasswordKey);

    try {
      return await storage.read();
    } catch (e) {
      console.error('biometric storage error: $e');
      return null;
    }
  }

  static Future<void> deletePassword() async {
    if (!await canAuthenticate()) return;
    final storage = await getStorage(kBiometricPasswordKey);
    await storage.delete();
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
      subtitle: WalletService.to.fileName,
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
    console.warning('biometric: $response');
    return response == CanAuthenticateResponse.success;
  }
}
