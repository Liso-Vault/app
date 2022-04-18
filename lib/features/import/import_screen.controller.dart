import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:either_option/either_option.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/services/wallet.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:path/path.dart';
import 'package:web3dart/web3dart.dart';

import '../../core/notifications/notifications.manager.dart';
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

  final ipfsUrlController = TextEditingController(
    text: PersistenceService.to.ipfsServerUrl,
  );

  // PROPERTIES
  final importMode = ImportMode.liso.obs;
  final ipfsBusy = false.obs;

  // GETTERS
  String get archiveFilePath => importMode() == ImportMode.file
      ? filePathController.text
      : LisoManager.tempVaultFilePath;

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

  Future<Either<dynamic, bool>> _downloadVault() async {
    final privateKey =
        WalletService.to.mnemonicToPrivateKey(seedController.text);
    final address = privateKey.address.hex;
    console.info('finding $address.$kVaultExtension...');

    // check if the vault exists
    final vaultPath = join(
      address,
      '$address.$kVaultExtension',
    );

    final downloadResult = await S3Service.to.downloadVault(path: vaultPath);
    File? vaultFile;
    dynamic _error;

    downloadResult.fold(
      (error) => _error = error,
      (file) => vaultFile = file,
    );

    if (_error != null) return Left(_error);
    final readResult = LisoManager.readArchive(vaultFile!.path);
    Archive? archive;

    readResult.fold(
      (error) => _error = error,
      (response) => archive = response,
    );

    console.info('archive files: ${archive!.files.length}');
    // check if archive contains files
    if (_error != null || archive!.files.isEmpty) {
      return Left('$_error > archive is empty');
    }

    return Right(true);
  }

  Future<void> continuePressed() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    if (!formKey.currentState!.validate()) return;

    change(null, status: RxStatus.loading());

    // download and save vault file from IPFS
    if (importMode.value == ImportMode.liso) {
      final downloadResult = await _downloadVault();
      bool successDownload = false;

      downloadResult.fold(
        (error) {
          //  TODO: offer to create vault instead

          UIUtils.showSimpleDialog(
            'Error Downloading',
            '$error > continuePressed()',
          );

          return change(null, status: RxStatus.success());
        },
        (response) => successDownload = response,
      );

      if (!successDownload) return change(null, status: RxStatus.success());
    }

    // read archive
    final result = LisoManager.readArchive(archiveFilePath);
    Archive? archive;
    dynamic _error;

    result.fold(
      (error) => _error = error,
      (response) => archive = response,
    );

    console.info('archive files: ${archive?.files.length}');

    if (archive == null || archive!.files.isEmpty) {
      UIUtils.showSimpleDialog(
        'Error Extracting',
        '$_error > continuePressed()',
      );

      return change(null, status: RxStatus.success());
    }

    // get items.hive file
    final itemsHiveFile = archive!.files.firstWhere(
      (e) => e.isFile && e.name.contains('items.hive'),
    );

    // temporarily extract for verification
    await LisoManager.extractArchiveFile(
      itemsHiveFile,
      path: LisoManager.tempPath,
    );
    // check if encryption key is correct
    final privateKeyHex =
        WalletService.to.mnemonicToPrivateKeyHex(seedController.text);

    final tempEncryptionKey = utf8.encode(privateKeyHex.substring(0, 32));
    final correctKey = await HiveManager.isEncryptionKeyCorrect(
      tempEncryptionKey,
    );

    if (!correctKey) {
      UIUtils.showSimpleDialog(
        'Incorrect Seed Phrase',
        'Please enter the mnemonic seed phrase you backed up to secure your vault.',
      );

      return change(null, status: RxStatus.success());
    }

    // extract all hive boxes
    await LisoManager.extractArchive(
      archive!,
      path: LisoManager.hivePath,
    );
    // turn on sync setting if successfully imported via cloud
    if (importMode.value == ImportMode.liso) {
      PersistenceService.to.sync.val = true;
    }

    change(null, status: RxStatus.success());

    NotificationsManager.notify(
      title: 'Successfully Imported Vault',
      body: basename(filePathController.text),
    );

    Get.toNamed(
      Routes.createPassword,
      parameters: {'privateKeyHex': privateKeyHex},
    );
  }

  void importFile() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    if (GetPlatform.isAndroid) FilePicker.platform.clearTemporaryFiles();
    change(null, status: RxStatus.loading());

    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
    } catch (e) {
      console.error('FilePicker error: $e');
      return;
    }

    change(null, status: RxStatus.success());

    if (result == null || result.files.isEmpty) {
      console.warning("canceled file picker");
      return;
    }

    filePathController.text = result.files.single.path!;
  }
}
