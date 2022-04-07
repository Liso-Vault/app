import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:path/path.dart';

import '../../core/notifications/notifications.manager.dart';
import '../../core/utils/ui_utils.dart';
import '../app/routes.dart';

class ImportScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ImportScreenController());
  }
}

class ImportScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final seedController = TextEditingController();
  final filePathController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

  Archive? _getArchive() {
    InputFileStream? inputStream;

    try {
      inputStream = InputFileStream(filePathController.text);
    } catch (e) {
      UIUtils.showSimpleDialog(
        'Error Importing Vault',
        e.toString(),
      );

      change(null, status: RxStatus.success());
      console.error('error importing archive: $e');
      return null;
    }

    return ZipDecoder().decodeBuffer(inputStream);
  }

  Future<void> _extractMainArchive() async {
    final archive = _getArchive();
    if (archive == null) return;

    for (var file in archive.files) {
      if (!file.isFile) continue;
      final path = join(LisoPaths.hive!.path, basename(file.name));
      final outputStream = OutputFileStream(path);
      file.writeContent(outputStream);
      await outputStream.close();
    }
  }

  Future<void> _extractTempItemsBox(ArchiveFile file) async {
    final outputStream =
        OutputFileStream(join(LisoPaths.temp!.path, basename(file.name)));
    file.writeContent(outputStream);
    await outputStream.close();
  }

  Future<void> continuePressed() async {
    // TODO: ask for read permission to prevent error

    if (!formKey.currentState!.validate()) return;
    if (seedController.text.isEmpty) return console.error('invalid mnemonic');
    if (status == RxStatus.loading()) return console.error('still busy');

    change(null, status: RxStatus.loading());

    // METHOD 1
    final archive = _getArchive();
    if (archive == null) return;

    // check if archive contains files
    if (archive.files.isEmpty) {
      UIUtils.showSimpleDialog(
        'Invalid Vault File',
        'The vault file you imported contains no files',
      );

      return change(null, status: RxStatus.success());
    }

    console.info('temp archive files: ${archive.files.length}');
    // filter items.hive file
    final itemBoxFiles =
        archive.files.where((e) => e.isFile && e.name.contains('items.hive'));
    // if items.hive is not found
    if (itemBoxFiles.isEmpty) {
      UIUtils.showSimpleDialog(
        'Invalid Vault',
        'The vault you imported contains no items',
      );

      return change(null, status: RxStatus.success());
    }

    // temporarily extract items box file
    await _extractTempItemsBox(itemBoxFiles.first);

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
    encryptionKey = tempEncryptionKey;

    // extract all hive boxes
    await _extractMainArchive();

    change(null, status: RxStatus.success());

    NotificationsManager.notify(
      title: 'Successfully Imported Vault File',
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
}
