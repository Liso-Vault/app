import 'dart:io';

import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/hive.service.dart';
import 'package:liso/core/supabase/supabase.service.dart';
import 'package:liso/features/files/explorer/s3_exporer_screen.controller.dart';
import 'package:liso/features/files/storage.service.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/liso/liso.manager.dart';
import '../../../core/liso/liso_paths.dart';
import '../../../core/notifications/notifications.manager.dart';
import '../../../core/persistence/persistence.secret.dart';
import '../../../core/services/cipher.service.dart';
import '../../../core/supabase/model/object.model.dart';
import '../../../core/utils/file.util.dart';
import '../../../core/utils/globals.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/utils/utils.dart';
import '../../attachments/attachments_screen.controller.dart';

class S3ObjectTileController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  String explorerType = '';

  // PROPERTIES
  final busy = false.obs;

  // INIT
  @override
  void change(newState, {RxStatus? status}) {
    busy.value = status?.isLoading ?? false;
    super.change(newState, status: status);
  }

  // FUNCTIONS
  void share(S3Object object) async {
    change('Sharing...', status: RxStatus.loading());
    final result = await SupabaseService.to.presignUrl(object: object.key);
    change('', status: RxStatus.success());

    if (result.isLeft) {
      return UIUtils.showSimpleDialog(
        'Sharing Failed',
        'Error: ${result.left}',
      );
    }

    final dialogContent = Text(
      '${object.name} will only be available to download for 1 hour from now.',
    );

    Get.dialog(AlertDialog(
      title: const Text('Share Securely'),
      content: Utils.isSmallScreen
          ? dialogContent
          : SizedBox(width: 450, child: dialogContent),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        if (GetPlatform.isMobile) ...[
          TextButton(
            child: const Text('Share URL'),
            onPressed: () {
              Get.back();
              Share.share(result.right.data.url);
            },
          ),
        ] else ...[
          TextButton(
            child: const Text('Copy URL'),
            onPressed: () {
              Get.back();
              Utils.copyToClipboard(result.right);
            },
          ),
        ]
      ],
    ));
  }

  void askToImport(S3Object object) {
    if (busy.value) return;

    final content = Text(
      'Are you sure you want to restore from this backed-up vault ${object.name}?\n\nIf you choose to proceed: Your current vault will be overwritten alongside with all the items in it.',
    );

    Get.dialog(AlertDialog(
      title: Text("${'restore'.tr} Backup"),
      content: Utils.isSmallScreen
          ? content
          : SizedBox(
              width: 450,
              child: content,
            ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          child: Text('proceed'.tr),
          onPressed: () => restore(object),
        ),
      ],
    ));
  }

  void restore(S3Object object) async {
    Get.back();

    change('Restoring...', status: RxStatus.loading());
    // purge all items
    await HiveService.to.purge();
    // download chosen vault file
    final downloadResult = await StorageService.to.download(object: object.key);

    if (downloadResult.isLeft) {
      change('Failed to download', status: RxStatus.success());

      return UIUtils.showSimpleDialog(
        'Failed To Download',
        '${downloadResult.left} -> download()',
      );
    }

    // re-upload to overwrite current vault file
    final uploadResult = await StorageService.to.upload(
      downloadResult.right,
      object: kVaultFileName,
    );

    if (uploadResult.isLeft) {
      change('Failed to upload', status: RxStatus.success());

      return UIUtils.showSimpleDialog(
        'Upload Failed',
        'Error: ${uploadResult.left}',
      );
    }

    // parse vault file
    final vault = await LisoManager.parseVaultBytes(
      downloadResult.right,
      cipherKey: SecretPersistence.to.cipherKey,
    );

    // import vault object & reload
    await LisoManager.importVault(
      vault,
      cipherKey: SecretPersistence.to.cipherKey,
    );

    MainScreenController.to.load();

    NotificationsManager.notify(
      title: 'Vault Restored',
      body: '${object.name} successfully restored!',
    );

    MainScreenController.to.navigate();
  }

  // TODO: confirmation dialog
  void confirmDelete(S3Object object) async {
    if (explorerType == 'picker') {
      AttachmentsScreenController.to.data.remove(object.etag);
      return;
    }

    void _delete() async {
      Get.back();
      change('Deleting...', status: RxStatus.loading());
      final result = await StorageService.to.remove(object.key);

      if (result.isLeft) {
        change(false, status: RxStatus.success());

        return UIUtils.showSimpleDialog(
          'Delete Failed',
          'Error: ${result.left}',
        );
      }

      NotificationsManager.notify(
        title: 'Deleted',
        body: object.name,
      );

      change('false', status: RxStatus.success());
      await S3ExplorerScreenController.to.load();
    }

    final dialogContent = Text(
      'Are you sure you want to delete "${object.name}"?',
    );

    Get.dialog(AlertDialog(
      title: Text('delete'.tr),
      content: Utils.isSmallScreen
          ? dialogContent
          : SizedBox(
              width: 450,
              child: dialogContent,
            ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: _delete,
          child: Text('confirm_delete'.tr),
        ),
      ],
    ));
  }

  void askToDownload(S3Object object) {
    final dialogContent = Text('Save "${object.maskedName}" to local disk?');

    Get.dialog(AlertDialog(
      title: const Text('Download'),
      content: Utils.isSmallScreen
          ? dialogContent
          : SizedBox(width: 450, child: dialogContent),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          child: const Text('Download'),
          onPressed: () {
            Get.back();
            _download(object);
          },
        ),
      ],
    ));
  }

  void _download(S3Object object) async {
    change('Downloading...', status: RxStatus.loading());
    final downloadPath = join(LisoPaths.temp!.path, object.name);

    final result = await StorageService.to.download(object: object.key);

    if (result.isLeft) {
      change('', status: RxStatus.success());

      return UIUtils.showSimpleDialog(
        'Failed To Download',
        '${result.left} -> download()',
      );
    }

    // decrypt file after downloading
    var file = File(downloadPath);

    await file.writeAsBytes(object.isEncrypted
        ? CipherService.to.decrypt(result.right)
        : result.right);

    final fileName = basename(file.path);
    Globals.timeLockEnabled = false; // temporarily disable

    if (GetPlatform.isMobile) {
      await Share.shareFiles(
        [file.path],
        subject: fileName,
        text: GetPlatform.isIOS ? null : fileName,
      );

      Globals.timeLockEnabled = true; // re-enable
      return change('', status: RxStatus.success());
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
    await FileUtils.move(file, join(exportPath, fileName));

    NotificationsManager.notify(
      title: 'Downloaded',
      body: fileName,
    );

    change('', status: RxStatus.success());
  }
}
