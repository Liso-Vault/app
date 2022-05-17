import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:liso/core/utils/file.util.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:minio/minio.dart';
import 'package:path/path.dart';

import '../../core/middlewares/authentication.middleware.dart';
import '../../core/utils/ui_utils.dart';
import '../app/routes.dart';
import '../s3/s3.service.dart';

class ImportScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ImportScreenController());
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

  // GETTERS
  String get archiveFilePath => importMode() == ImportMode.file
      ? filePathController.text
      : LisoManager.tempVaultFilePath;

  Future<bool> get canPop async => !busy.value;

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  @override
  void change(newState, {RxStatus? status}) {
    busy.value = status == RxStatus.loading();
    super.change(newState, status: status);
  }

  // FUNCTIONS

  Future<bool> _downloadVault() async {
    final privateKey = WalletService.to.mnemonicToPrivateKey(
      seedController.text,
    );

    final address = privateKey.address.hexEip55;
    final result = await S3Service.to.downloadFile(
      s3Path: join(address, '$address.$kVaultExtension').replaceAll('\\', '/'),
      filePath: LisoManager.tempVaultFilePath,
      force: true,
    );

    if (result.isRight || result.left == null) return true;
    final newUser = result.left is MinioError &&
        result.left.message!.contains('does not exist');

    if (newUser) {
      UIUtils.showSimpleDialog(
        'Vault Not Found',
        "It looks like you're a new user. Consider creating a vault instead and start securing your data.",
      );
    } else {
      UIUtils.showSimpleDialog(
        'Error Downloading',
        '${result.left} > _downloadVault(), ${S3Service.to.client!.accessKey} | ${S3Service.to.client!.endPoint} | ${S3Service.to.client!.secretKey}',
      );
    }

    // delete temp downloaded vault
    FileUtils.delete(archiveFilePath);
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

    // read archive
    final result = LisoManager.readArchive(archiveFilePath);
    FileUtils.delete(archiveFilePath); // delete temp downloaded vault

    if (result.isLeft) {
      UIUtils.showSimpleDialog(
        'Error Extracting',
        '${result.left} > continuePressed()',
      );

      return change(null, status: RxStatus.success());
    }

    final archive = result.right;
    // extract to temp directory for verification
    await LisoManager.extractArchive(
      archive,
      path: LisoManager.tempPath,
    );

    // check if encryption key is correct
    final credentials = WalletService.to.mnemonicToPrivateKey(
      seedController.text,
    );

    final isCorrect = await HiveManager.isEncryptionKeyCorrect(
      credentials.privateKey,
    );

    if (!isCorrect) {
      UIUtils.showSimpleDialog(
        'Incorrect Seed Phrase',
        'Please enter the mnemonic seed phrase you backed up to secure your vault.',
      );

      return change(null, status: RxStatus.success());
    }

    // move temporarily extracted hive files to main hive directory
    final tempItemsFile = File(join(
      LisoManager.tempPath,
      '$kHiveBoxItems.hive',
    ));

    final destinationItemsPath = join(
      LisoManager.hivePath,
      '$kHiveBoxItems.hive',
    );

    await FileUtils.move(tempItemsFile, destinationItemsPath);
    // ignore syncing screen if we just imported
    AuthenticationMiddleware.ignoreSync = true;
    // turn on sync setting if successfully imported via cloud
    PersistenceService.to.sync.val =
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
