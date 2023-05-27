import 'dart:convert';
import 'dart:io';

import 'package:app_core/config/app.model.dart';

import 'package:app_core/globals.dart';
import 'package:app_core/notifications/notifications.manager.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/cipher.service.dart';
import '../../core/utils/file.util.dart';
import '../../core/utils/globals.dart';

class CipherScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static CipherScreenController get to => Get.find();

  // VARIABLES
  final encryptController = TextEditingController();
  final decryptController = TextEditingController();

  // PROPERTIES
  final busy = false.obs;

  // PROPERTIES

  // GETTERS

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

  void encrypt() async {
    timeLockEnabled = false; // temporarily disable
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Encrypt a File',
        type: FileType.any,
      );
    } catch (e) {
      timeLockEnabled = true; // re-enable
      console.error('FilePicker error: $e');
      return;
    }

    if (result == null || result.files.isEmpty) {
      timeLockEnabled = true; // re-enable
      console.warning("canceled file picker");
      return;
    }

    // TODO: temporary
    // if (!limits.cipherTool) {
    //   return Utils.adaptiveRouteOpen(
    //     name: Routes.upgrade,
    //     parameters: {
    //       'title': 'Encryption Tool',
    //       'body':
    //           'Encrypt your ${GetPlatform.isDesktop ? 'computer' : 'precious'} files to protect them from hackers and unwanted access. Using the same military-grade encryption ${appConfig.name} uses to protect your vault. Upgrade to Pro to take advantage of this powerful feature.',
    //     },
    //   );
    // }

    change(false, status: RxStatus.loading());
    final stopwatch = Stopwatch()..start();

    final path = result.files.single.path!;
    final name = basename(path);
    console.info('path: $path');

    if (name.contains(kEncryptedExtensionExtra)) {
      timeLockEnabled = true; // re-enable
      change(null, status: RxStatus.success());
      return UIUtils.showSimpleDialog(
        'Already Encrypted',
        'It looks like the file $name is already encrypted.',
      );
    }

    final inputFile = File(path);
    final bytes = await inputFile.readAsBytes();
    console.info('plain bytes: ${bytes.sublist(0, 10)}');

    final outputFile = await CipherService.to.encryptFile(inputFile);
    final outputBytes = await outputFile.readAsBytes();
    console.warning('encrypted bytes: ${outputBytes.sublist(0, 10)}');
    console.debug('executed in ${stopwatch.elapsed.inSeconds} seconds');

    if (GetPlatform.isMobile) {
      await Share.shareFiles(
        [outputFile.path],
        subject: name,
        text: GetPlatform.isIOS ? null : name,
      );

      timeLockEnabled = true; // re-enable
      return change(false, status: RxStatus.success());
    }

    // choose directory and export file
    final exportPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose Export Path',
    );

    timeLockEnabled = true; // re-enable
    // user cancelled picker
    if (exportPath == null) {
      return change(null, status: RxStatus.success());
    }

    console.info('export path: $exportPath');
    await Future.delayed(1.seconds); // just for style

    await FileUtils.move(
      outputFile,
      join(exportPath, basename(outputFile.path)),
    );

    NotificationsManager.notify(
      title: 'Encrypted',
      body: name,
    );

    change(false, status: RxStatus.success());
  }

  void decrypt() async {
    timeLockEnabled = false; // temporarily disable
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Decrypt a <file>$kEncryptedExtensionExtra file',
        allowedExtensions: [kEncryptedExtensionExtra],
        type: FileType.any,
      );
    } catch (e) {
      timeLockEnabled = true; // re-enable
      console.error('FilePicker error: $e');
      return;
    }

    if (result == null || result.files.isEmpty) {
      timeLockEnabled = true; // re-enable
      console.warning("canceled file picker");
      return;
    }

    change(false, status: RxStatus.loading());
    final stopwatch = Stopwatch()..start();

    final path = result.files.single.path!;
    final name = basename(path);
    console.info('$name, path: $path');

    if (!name.contains('.$kVaultExtension') &&
        !name.contains(kEncryptedExtensionExtra)) {
      timeLockEnabled = true; // re-enable
      change(null, status: RxStatus.success());
      return UIUtils.showSimpleDialog(
        'Invalid ${appConfig.name} Encrypted File',
        'It looks like the file $name is not a ${appConfig.name} Encrypted File which should have an extension of $kEncryptedExtensionExtra',
      );
    }

    final inputFile = File(path);
    final bytes = await inputFile.readAsBytes();
    console.info('decrypted bytes: ${bytes.sublist(0, 10)}');

    final outputFile = await CipherService.to.decryptFile(inputFile);
    final outputBytes = await outputFile.readAsBytes();
    console.warning('decrypted bytes: ${outputBytes.sublist(0, 10)}');
    console.debug('executed in ${stopwatch.elapsed.inSeconds} seconds');

    if (GetPlatform.isMobile) {
      await Share.shareFiles(
        [outputFile.path],
        subject: name,
        text: GetPlatform.isIOS ? null : name,
      );

      timeLockEnabled = true; // re-enable
      return change(false, status: RxStatus.success());
    }

    // choose directory and export file
    final exportPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose Export Path',
    );

    timeLockEnabled = true; // re-enable
    // user cancelled picker
    if (exportPath == null) {
      return change(null, status: RxStatus.success());
    }

    console.info('export path: $exportPath');
    await Future.delayed(1.seconds); // just for style

    await FileUtils.move(
      outputFile,
      join(exportPath, basename(outputFile.path)),
    );

    NotificationsManager.notify(
      title: 'Decrypted',
      body: name,
    );

    change(false, status: RxStatus.success());
  }

  void encryptText() async {
    final formKey = GlobalKey<FormState>();
    final textController = TextEditingController();

    void encrypt() async {
      if (!formKey.currentState!.validate()) return;

      final encrypted = CipherService.to.encrypt(
        utf8.encode(textController.text),
      );

      final encoded = base64Encode(encrypted);

      UIUtils.showSimpleDialog(
        'Encrypted Text',
        encoded,
        action: () => Utils.copyToClipboard(encoded),
        actionText: 'Copy',
      );
    }

    final content = TextFormField(
      controller: textController,
      minLines: 1,
      maxLines: 5,
      validator: (data) => data!.isEmpty ? 'Required' : null,
      decoration: const InputDecoration(
        labelText: 'Text',
        hintText: 'Enter the text to encrypt',
      ),
    );

    Get.dialog(AlertDialog(
      title: Text('encrypt_text'.tr),
      content: Form(
        key: formKey,
        child: isSmallScreen ? content : SizedBox(width: 450, child: content),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: encrypt,
          child: Text('encrypt'.tr),
        ),
      ],
    ));
  }

  void decryptText() async {
    final formKey = GlobalKey<FormState>();
    final textController = TextEditingController();

    void decrypt() async {
      if (!formKey.currentState!.validate()) return;

      final encrypted = CipherService.to.decrypt(
        base64Decode(textController.text),
      );

      final decoded = utf8.decode(encrypted);

      UIUtils.showSimpleDialog(
        'Decrypted Text',
        decoded,
        action: () => Utils.copyToClipboard(decoded),
        actionText: 'Copy',
      );
    }

    final content = TextFormField(
      controller: textController,
      minLines: 1,
      maxLines: 5,
      validator: (data) => data!.isEmpty ? 'Required' : null,
      decoration: const InputDecoration(
        labelText: 'Encrypted Text',
        hintText: 'Enter the encrypted & base64 encoded text to decrypt',
      ),
    );

    Get.dialog(AlertDialog(
      title: Text('decrypt_text'.tr),
      content: Form(
        key: formKey,
        child: isSmallScreen ? content : SizedBox(width: 450, child: content),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: decrypt,
          child: Text('decrypt'.tr),
        ),
      ],
    ));
  }
}
