import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/ipfs/ipfs.service.dart';
import 'package:path/path.dart';
import 'package:web3dart/web3dart.dart';

import '../../core/notifications/notifications.manager.dart';
import '../../core/utils/ui_utils.dart';
import '../app/routes.dart';

class ImportScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ImportScreenController());
  }
}

enum ImportMode {
  file,
  ipfs,
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
  final importMode = ImportMode.file.obs;
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
  Future<void> _extractMainArchive() async {
    final result = LisoManager.readArchive(archiveFilePath);
    Archive? archive;

    result.fold(
      (error) => console.error('extract archive error: $error'),
      (response) => archive = response,
    );

    if (archive == null) return;
    await LisoManager.extractArchive(archive!, path: LisoManager.hivePath);
  }

  Future<bool> _downloadVault() async {
    final seedHex = bip39.mnemonicToSeedHex(seedController.text);
    final address = EthPrivateKey.fromHex(seedHex).address.hexEip55;
    console.info('finding $address.$kVaultExtension...');
    // check if the vault exists
    final ipfsVaultPath = join(
      '/$kAppName',
      address,
      address + '.$kVaultExtension',
    );

    // /Liso/0x123EA62e9A059B29f8886f57E3AB2dea4B809965/0x123EA62e9A059B29f8886f57E3AB2dea4B809965.liso
    final resultStat = await IPFSService.to.ipfs.files.stat(arg: ipfsVaultPath);

    String? vaultHash;

    resultStat.fold(
      (error) {
        if (error.message.contains('does not exist')) {
          return UIUtils.showSimpleDialog(
            'No Vault Found',
            'We did not find a vault: $ipfsVaultPath in your IPFS Server. Please create a new vault if you\'re new to $kAppName then you can sync to IPFS after',
          );
        }

        return UIUtils.showSimpleDialog(
          'IPFS Stat Error',
          '${error.toJson()} > continuePressed()',
        );
      },
      (response) {
        vaultHash = response.hash!;
        console.info('vault hash: $vaultHash');
      },
    );

    if (vaultHash == null) {
      console.error('vault hash is empty for some reason');
      return false;
    }

    // start download
    // TODO: download progress indicator
    final resultDownload = await IPFSService.to.ipfs.root.cat(
      arg: vaultHash,
      savePath: LisoManager.tempVaultFilePath,
    );

    bool downloaded = false;

    resultDownload.fold(
      (error) => UIUtils.showSimpleDialog(
          'IPFS Download Error', error.toJson().toString()),
      (response) => downloaded = true,
    );

    return downloaded;
  }

  Future<void> continuePressed() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    if (!formKey.currentState!.validate()) return;

    change(null, status: RxStatus.loading());

    if (importMode.value == ImportMode.ipfs) {
      final connected = await checkIPFS(showSuccess: false);
      if (!connected) return change(null, status: RxStatus.success());
    }

    // download and save vault file from IPFS
    if (importMode.value == ImportMode.ipfs) {
      final success = await _downloadVault();
      if (!success) return change(null, status: RxStatus.success());
    }

    // METHOD 1
    final result = LisoManager.readArchive(archiveFilePath);

    Archive? archive;

    result.fold(
      (error) => console.error('extract archive error: $error'),
      (response) => archive = response,
    );

    if (archive == null) return change(null, status: RxStatus.success());

    // check if archive contains files
    if (archive!.files.isEmpty) {
      UIUtils.showSimpleDialog(
        'Invalid Vault File',
        'The vault file you imported contains no files',
      );

      return change(null, status: RxStatus.success());
    }

    console.info('temp archive files: ${archive!.files.length}');
    // filter items.hive file
    final itemBoxFiles =
        archive!.files.where((e) => e.isFile && e.name.contains('items.hive'));
    // if items.hive is not found
    if (itemBoxFiles.isEmpty) {
      UIUtils.showSimpleDialog(
        'Invalid Vault',
        'The vault you imported contains no items',
      );

      return change(null, status: RxStatus.success());
    }

    // temporarily extract items box file
    await LisoManager.extractArchiveFile(
      itemBoxFiles.first,
      path: LisoManager.tempPath,
    );
    // check if encryption key is correct
    final seedHex = bip39.mnemonicToSeedHex(seedController.text);
    final tempEncryptionKey = utf8.encode(seedHex.substring(0, 32));
    final correctKey =
        await HiveManager.isEncryptionKeyCorrect(tempEncryptionKey);

    if (!correctKey) {
      UIUtils.showSimpleDialog(
        'Incorrect Seed Phrase',
        'Please enter the corresponding mnemonic seed phrase used to secure your vault.',
      );

      return change(null, status: RxStatus.success());
    }

    // set the correct encryption key
    Globals.encryptionKey = tempEncryptionKey;
    // extract all hive boxes
    await _extractMainArchive();

    // turn on IPFS sync if successfully imported via IPFS
    if (importMode.value == ImportMode.ipfs) {
      PersistenceService.to.ipfsSync.val = true;
    }

    change(null, status: RxStatus.success());

    NotificationsManager.notify(
      title: 'Successfully Imported Vault',
      body: basename(filePathController.text),
    );

    Get.toNamed(Routes.createPassword, parameters: {'seedHex': seedHex});
  }

  void importFile() async {
    if (status == RxStatus.loading()) return console.error('still busy');
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

  Future<bool> checkIPFS({bool showSuccess = true}) async {
    ipfsBusy.value = true;

    final uri = Uri.tryParse(ipfsUrlController.text);
    if (uri == null) return false;

    // save to persistence
    final persistence = Get.find<PersistenceService>();
    persistence.ipfsScheme.val = uri.scheme;
    persistence.ipfsHost.val = uri.host;
    persistence.ipfsPort.val = uri.port;

    final connected = await IPFSService.to.init();
    ipfsBusy.value = false;

    if (!connected) {
      UIUtils.showSimpleDialog(
        'IPFS Connection Failed',
        'Failed to connect to: ${ipfsUrlController.text}\nDouble check the Server URL and make sure your IPFS Node is up and running',
      );
    } else if (showSuccess) {
      UIUtils.showSimpleDialog(
        'IPFS Connection Success',
        'Successfully connects to your server: ${ipfsUrlController.text}\nYou\'re now ready to sync.',
      );
    }

    return connected;
  }
}
