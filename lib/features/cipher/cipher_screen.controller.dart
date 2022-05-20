import 'dart:io';

import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/services/cipher.service.dart';
import '../../core/notifications/notifications.manager.dart';
import '../../core/utils/file.util.dart';
import '../../core/utils/globals.dart';

class CipherScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CipherScreenController());
  }
}

class CipherScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static CipherScreenController get to => Get.find();

  // VARIABLES

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
    Globals.timeLockEnabled = false; // temporarily disable
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Encrypt a File',
        type: FileType.any,
      );
    } catch (e) {
      Globals.timeLockEnabled = true; // re-enable
      console.error('FilePicker error: $e');
      return;
    }

    if (result == null || result.files.isEmpty) {
      Globals.timeLockEnabled = true; // re-enable
      console.warning("canceled file picker");
      return;
    }

    change(false, status: RxStatus.loading());
    final stopwatch = Stopwatch()..start();

    final path = result.files.single.path!;
    final name = basename(path);
    console.info('path: $path');

    if (name.contains(kEncryptedExtensionExtra)) {
      Globals.timeLockEnabled = true; // re-enable
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

      Globals.timeLockEnabled = true; // re-enable
      return change(false, status: RxStatus.success());
    }

    // choose directory and export file
    final exportPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose Export Path',
    );

    Globals.timeLockEnabled = true; // re-enable
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
    Globals.timeLockEnabled = false; // temporarily disable
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Decrypt a <file>$kEncryptedExtensionExtra file',
        allowedExtensions: [kEncryptedExtensionExtra],
        type: FileType.any,
      );
    } catch (e) {
      Globals.timeLockEnabled = true; // re-enable
      console.error('FilePicker error: $e');
      return;
    }

    if (result == null || result.files.isEmpty) {
      Globals.timeLockEnabled = true; // re-enable
      console.warning("canceled file picker");
      return;
    }

    change(false, status: RxStatus.loading());
    final stopwatch = Stopwatch()..start();

    final path = result.files.single.path!;
    final name = basename(path);
    console.info('$name, path: $path');

    if (!name.contains(kEncryptedExtensionExtra)) {
      Globals.timeLockEnabled = true; // re-enable
      change(null, status: RxStatus.success());
      return UIUtils.showSimpleDialog(
        'Invalid ${ConfigService.to.appName} Encrypted File',
        'It looks like the file $name is not a ${ConfigService.to.appName} Encrypted File which should have an extension of $kEncryptedExtensionExtra',
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

      Globals.timeLockEnabled = true; // re-enable
      return change(false, status: RxStatus.success());
    }

    // choose directory and export file
    final exportPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose Export Path',
    );

    Globals.timeLockEnabled = true; // re-enable
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
}
