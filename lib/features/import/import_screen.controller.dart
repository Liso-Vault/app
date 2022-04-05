import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/liso/liso_crypter.model.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/notifications/notifications.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';

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

  void continuePressed() async {
    if (!formKey.currentState!.validate()) return;
    if (seedController.text.isEmpty) return console.error('invalid mnemonic');
    if (status == RxStatus.loading()) return console.error('still busy');

    change(null, status: RxStatus.loading());

    final masterSeedHex = bip39.mnemonicToSeedHex(seedController.text);
    // TODO: what if we could use entropy as the 32 bytes encryption key instead
    // final masterEntropy = bip39.mnemonicToEntropy(seedController.text);
    // console.warning('Entropy: $masterEntropy, Length: ${masterEntropy.length}');
    final masterPassword = masterSeedHex.substring(0, 32);

    // the encryption key from master's private key
    encryptionKey = utf8.encode(masterPassword);
    // initialize crypter with encryption key
    final crypter = LisoCrypter();
    await crypter.initSecretKey(encryptionKey!);

    // // WORKS ONLY FOR ZIP
    // await extractFileToDisk(filePathController.text, LisoPaths.main!.path);

    // WORKS FOR .LISO
    final inputStream = InputFileStream(filePathController.text);
    final archive = ZipDecoder().decodeBuffer(inputStream);
    extractArchiveToDisk(archive, LisoPaths.main!.path);

    change(null, status: RxStatus.success());

    NotificationsManager.notify(
      title: 'Successfully Imported Vault File',
      body: filePathController.text,
    );

    Get.toNamed(Routes.createPassword, parameters: {'seedHex': masterSeedHex});
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
