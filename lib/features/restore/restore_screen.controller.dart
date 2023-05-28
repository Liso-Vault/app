import 'dart:io';

import 'package:app_core/config/app.model.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/notifications/notifications.manager.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/services/local_auth.service.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/services/cipher.service.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:path/path.dart';

import '../../core/liso/liso.manager.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../supabase/supabase_functions.service.dart';

class RestoreScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final seedController = TextEditingController();
  final filePathController = TextEditingController();

  // PROPERTIES
  final restoreMode = RestoreMode.cloud.obs;
  final busy = false.obs;
  final syncProvider = LisoSyncProvider.sia.name.obs;

  // GETTERS

  Future<bool> get canPop async => !busy.value;

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  @override
  void change(newState, {RxStatus? status}) {
    busy.value = status?.isLoading ?? false;
    super.change(newState, status: status);
  }

  // FUNCTIONS

  Future<Either<String, Uint8List>> _downloadVault(String address) async {
    final statResult = await AppFunctionsService.to.statObject(
      kVaultFileName,
      address: address,
    );

    if (statResult.isLeft || statResult.right.status != 200) {
      return Left(
        "If you're new to ${appConfig.name}, consider creating a vault first.",
      );
    }

    final presignResult = await AppFunctionsService.to.presignUrl(
      object: kVaultFileName,
      address: address,
      method: 'GET',
    );

    if (presignResult.isLeft || presignResult.right.status != 200) {
      return const Left("Failed to presign 1");
    }

    final response = await http.get(Uri.parse(presignResult.right.data.url));

    if (response.statusCode != 200) {
      return Left("Failed to presign: ${response.statusCode}");
    }

    return Right(response.bodyBytes);
  }

  Future<void> continuePressed() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    if (!formKey.currentState!.validate()) return;
    change(null, status: RxStatus.loading());

    final seed = seedController.text.trim();
    final credentials = WalletService.to.mnemonicToPrivateKey(seed);
    final address = credentials.address.hexEip55;

    Uint8List bytes;

    // download vault file
    if (restoreMode.value == RestoreMode.cloud) {
      final result = await _downloadVault(address);

      if (result.isLeft) {
        change(null, status: RxStatus.success());

        return UIUtils.showSimpleDialog(
          'Failed Restoring Vault',
          result.left,
        );
      }

      bytes = result.right;
    } else {
      bytes = await File(filePathController.text).readAsBytes();
    }

    final cipherKey = await WalletService.to.credentialsToCipherKey(
      credentials,
    );

    final canDecrypt = await CipherService.to.canDecrypt(
      bytes,
      cipherKey,
    );

    if (!canDecrypt) {
      change(null, status: RxStatus.success());

      return UIUtils.showSimpleDialog(
        'Failed Decrypting Vault',
        'Please check your seed phrase',
      );
    }

    final vault = await LisoManager.parseVaultBytes(
      bytes,
      cipherKey: cipherKey,
    );

    Future<void> proceed() async {
      // parse and import vault file
      await LisoManager.importVault(
        vault,
        cipherKey: cipherKey,
      );
      // turn on sync setting if successfully imported via cloud
      AppPersistence.to.sync.val =
          restoreMode.value == RestoreMode.cloud ? true : false;

      if (isLocalAuthSupported) {
        final authenticated = await LocalAuthService.to.authenticate(
          subTitle: 'Restore your vault',
          body: 'Authenticate to verify and approve this action',
        );

        if (!authenticated) return change(null, status: RxStatus.success());
        Get.back(); // close dialog
        // AuthenticationMiddleware.signedIn = true;
        final password = AppUtils.generatePassword();
        await WalletService.to.create(seed, password, false);
        change(null, status: RxStatus.success());
        AppPersistence.to.backedUpSeed.val = true;

        NotificationsManager.notify(
          title: 'Welcome back to ${appConfig.name}',
          body: 'Your vault has been restored',
        );

        Get.offNamedUntil(Routes.main, (route) => false);
      } else {
        change(null, status: RxStatus.success());

        Utils.adaptiveRouteOpen(
          name: AppRoutes.createPassword,
          parameters: {'seed': seed, 'from': 'restore_screen'},
        );
      }
    }

    await UIUtils.showImageDialog(
      Icon(Iconsax.import, size: 100, color: themeColor),
      title: 'restore_vault'.tr,
      subTitle: address,
      body:
          "Device: ${vault.metadata!.device.name}\nApp Version: ${vault.metadata!.app.formattedVersion}\nLast Modified: ${vault.metadata!.updatedTime}\nVault Version: ${vault.version}",
      action: proceed,
      actionText: 'Restore',
      closeText: 'Cancel',
      onClose: Get.back,
    );

    change(null, status: RxStatus.success());
  }

  void importFile() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    if (GetPlatform.isAndroid) FilePicker.platform.clearTemporaryFiles();
    change(null, status: RxStatus.loading());

    timeLockEnabled = false; // disable
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
    } catch (e) {
      timeLockEnabled = true; // re-enable
      console.error('FilePicker error: $e');
      return;
    }

    change(null, status: RxStatus.success());

    if (result == null || result.files.isEmpty) {
      timeLockEnabled = true; // re-enable
      console.warning("canceled file picker");
      return;
    }

    final filePath = result.files.single.path!;
    final valid = extension(filePath) == '.$kVaultExtension';

    if (!valid) {
      return UIUtils.showSimpleDialog(
        'Invalid Vault',
        'You can only restore an encrypted <vault>.$kVaultExtension file',
      );
    }

    filePathController.text = filePath;
  }
}

enum RestoreMode { file, cloud }
