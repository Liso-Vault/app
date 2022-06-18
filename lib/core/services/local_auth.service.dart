import 'package:app_settings/app_settings.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/firebase/crashlytics.service.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

import '../../features/wallet/wallet.service.dart';
import '../persistence/persistence.dart';
// import 'package:local_auth_windows/local_auth_windows.dart';

class LocalAuthService extends GetxService with ConsoleMixin {
  static LocalAuthService get to => Get.find<LocalAuthService>();

  // VARIABLES
  final auth = LocalAuthentication();

  // PROPERTIES

  // INIT

  // FUNCTIONS

  Future<bool> authenticate() async {
    bool authenticated = false;

    try {
      // TODO: localize
      authenticated = await auth.authenticate(
        localizedReason: 'Decrypt and access your local vault',
        options: const AuthenticationOptions(),
        authMessages: [
          AndroidAuthMessages(
            signInTitle: 'Authenticate ${ConfigService.to.appName}',
            biometricHint: 'Unlock your vault',
            cancelButton: 'Cancel',
          ),
          const IOSAuthMessages(cancelButton: 'Cancel'),
          // const WindowsAuthMessages(),
        ],
      );
    } on PlatformException catch (e, s) {
      console.error('exception: ${e.toString()}');

      if (e.code == auth_error.notAvailable) {
        _onError(e);
      } else if (e.code == auth_error.notEnrolled) {
        _onError(e);
      } else if (e.code == auth_error.passcodeNotSet) {
        _onError(e);
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        UIUtils.showSimpleDialog(
          'Locked Out',
          "Because of too many attempts you've been locked out. Please try again later.",
        );
      } else if (e.code == auth_error.otherOperatingSystem) {
        _failedAuth(e);
      } else {
        CrashlyticsService.to.record(e, s);
        _failedAuth(e);
      }

      return false;
    } catch (e, s) {
      console.error('error: ${e.toString()}');
      CrashlyticsService.to.record(e, s);
      _failedAuth(e);
      return false;
    }

    return authenticated;
  }

  void _onError(dynamic e) {
    if (WalletService.to.isReady) {
      _showError();
    } else {
      _failedAuth(e);
    }
  }

  void _showError() {
    UIUtils.showSimpleDialog(
      'Screenlock Required',
      "Please turn it on to continue.",
      closeText: 'Cancel',
      actionText: 'Open Settings',
      action: () {
        Get.back();
        AppSettings.openLockAndPasswordSettings();
      },
    );
  }

  void _failedAuth(dynamic e) {
    Persistence.to.biometrics.val = false;

    UIUtils.showSimpleDialog(
      'Failed Biometrics',
      'Please try again using Master Passwords instead\n\n$e',
    );
  }
}
