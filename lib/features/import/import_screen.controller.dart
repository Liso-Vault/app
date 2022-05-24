import 'dart:io';

import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/services/cipher.service.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/file.util.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:minio/minio.dart';
import 'package:path/path.dart';

import '../../core/liso/liso_paths.dart';
import '../../core/middlewares/authentication.middleware.dart';
import '../../core/utils/ui_utils.dart';
import '../app/routes.dart';
import '../s3/s3.service.dart';

class ImportScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ImportScreenController(), fenix: true);
  }
}

enum ImportMode {
  file,
  liso,
  s3,
}

class ImportScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final seedController = TextEditingController();
  final filePathController = TextEditingController();

  // PROPERTIES
  final importMode = ImportMode.liso.obs;
  final busy = false.obs;
  final syncProvider = LisoSyncProvider.sia.name.obs;

  // GETTERS
  String get vaultFilePath => importMode() == ImportMode.file
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

  Future<bool> _downloadVault() async {
    final privateKey = WalletService.to.mnemonicToPrivateKey(
      seedController.text,
    );

    final address = privateKey.address.hexEip55;
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

    // download vault file
    if (importMode.value == ImportMode.liso) {
      if (!(await _downloadVault())) {
        return change(null, status: RxStatus.success());
      }
    }

    final credentials = WalletService.to.mnemonicToPrivateKey(
      seedController.text,
    );

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
    await HiveManager.importVaultFile(vaultFile, cipherKey: cipherKey);
    // ignore syncing screen if we just imported
    AuthenticationMiddleware.ignoreSync = true;
    // turn on sync setting if successfully imported via cloud
    Persistence.to.sync.val =
        importMode.value == ImportMode.liso ? true : false;
    change(null, status: RxStatus.success());

    Get.offNamed(
      Routes.createPassword,
      parameters: {
        'privateKeyHex': HEX.encode(credentials.privateKey),
        'seed': seedController.text,
      },
    );
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
