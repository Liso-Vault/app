import 'dart:io';

import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/services/cipher.service.dart';
import 'package:liso/core/utils/file.util.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:minio/minio.dart';
import 'package:path/path.dart';

import '../../core/liso/liso.manager.dart';
import '../../core/liso/liso_paths.dart';
import '../../core/services/local_auth.service.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../s3/s3.service.dart';

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
  String get vaultFilePath => restoreMode.value == RestoreMode.file
      ? filePathController.text
      : LisoPaths.tempVaultFilePath;

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

  Future<bool> _downloadVault(String address) async {
    final s3VaultPath = join(address, kVaultFileName).replaceAll('\\', '/');

    final result = await S3Service.to.downloadFile(
      s3Path: s3VaultPath,
      filePath: LisoPaths.tempVaultFilePath,
      force: true,
    );

    if (result.isRight || result.left == null) return true;
    final newUser = result.left is MinioError &&
        result.left.message!.contains('does not exist');

    if (newUser) {
      UIUtils.showSimpleDialog(
        'Vault Not Found',
        "Please make sure you selected the right provider. Or if you're new to ${ConfigService.to.appName}, consider creating a vault and start securing your data.",
      );
    } else {
      UIUtils.showSimpleDialog(
        'Error Downloading',
        '${result.left} > _downloadVault()',
      );
    }

    // delete temp downloaded vault
    FileUtils.delete(vaultFilePath);
    return false;
  }

  Future<void> continuePressed() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    if (!formKey.currentState!.validate()) return;
    change(null, status: RxStatus.loading());

    final seed = seedController.text;
    final credentials = WalletService.to.mnemonicToPrivateKey(seed);

    // download vault file
    if (restoreMode.value == RestoreMode.cloud) {
      if (!(await _downloadVault(credentials.address.hexEip55))) {
        return change(null, status: RxStatus.success());
      }
    }

    final cipherKey = await WalletService.to.credentialsToCipherKey(
      credentials,
    );

    final vaultFile = File(vaultFilePath);
    final canDecrypt = await CipherService.to.canDecrypt(
      vaultFile,
      cipherKey,
    );

    if (!canDecrypt) {
      change(null, status: RxStatus.success());

      return UIUtils.showSimpleDialog(
        'Failed Decrypting Vault',
        'Please check your seed phrase',
      );
    }

    // parse and import vault file
    await LisoManager.importVaultFile(vaultFile, cipherKey: cipherKey);
    // turn on sync setting if successfully imported via cloud
    Persistence.to.sync.val =
        restoreMode.value == RestoreMode.cloud ? true : false;
    change(null, status: RxStatus.success());

    if (isLocalAuthSupported) {
      final authenticated = await LocalAuthService.to.authenticate();
      if (!authenticated) return;
      final password = Utils.generatePassword();
      await WalletService.to.create(seed, password, false);
      Get.offNamedUntil(Routes.main, (route) => false);
    } else {
      Utils.adaptiveRouteOpen(
        name: Routes.createPassword,
        parameters: {
          'seed': seed,
          'from': 'restore_screen',
        },
      );
    }
  }

  void importFile() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    if (GetPlatform.isAndroid) FilePicker.platform.clearTemporaryFiles();
    change(null, status: RxStatus.loading());

    Globals.timeLockEnabled = false; // disable
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
    } catch (e) {
      Globals.timeLockEnabled = true; // re-enable
      console.error('FilePicker error: $e');
      return;
    }

    change(null, status: RxStatus.success());

    if (result == null || result.files.isEmpty) {
      Globals.timeLockEnabled = true; // re-enable
      console.warning("canceled file picker");
      return;
    }

    filePathController.text = result.files.single.path!;
  }
}

enum RestoreMode {
  file,
  cloud,
  s3,
}
