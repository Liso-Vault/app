import 'dart:io';

import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/features/s3/explorer/s3_exporer_screen.controller.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/liso/liso_paths.dart';
import '../../../core/notifications/notifications.manager.dart';
import '../../../core/services/cipher.service.dart';
import '../../../core/utils/file.util.dart';
import '../../../core/utils/globals.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/utils/utils.dart';
import '../../attachments/attachments_screen.controller.dart';
import '../model/s3_content.model.dart';
import '../s3.service.dart';

class S3ContentTileController extends GetxController
    with StateMixin, ConsoleMixin {
  String explorerType = '';

  void share(S3Content content) async {
    change(true, status: RxStatus.loading());
    final result = await S3Service.to.getPreSignedUrl(content.path);
    change(false, status: RxStatus.success());

    if (result.isLeft) {
      return UIUtils.showSimpleDialog(
        'Create Folder Failed',
        'Error: ${result.left}',
      );
    }

    final dialogContent = Text(
      '${content.name} will only be available to download for 1 hour from now.',
    );

    Get.dialog(AlertDialog(
      title: const Text('Share Securely'),
      content: Utils.isDrawerExpandable
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
              Share.share(result.right);
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

  void askToImport(S3Content s3content) {
    const content = Text(
      'Are you sure you want to restore from this vault? \nYour current vault will be overwritten.',
    );

    Get.dialog(AlertDialog(
      title: Text('restore'.tr),
      content: Utils.isDrawerExpandable
          ? content
          : const SizedBox(
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
          onPressed: () => restore(s3content),
        ),
      ],
    ));
  }

  void backup(S3Content content) async {
    final result = await S3Service.to.backup(content);

    result.either(
      (error) => UIUtils.showSimpleDialog(
        'Error Backup',
        error,
      ),
      (response) => console.info('success: $response'),
    );
  }

  void restore(S3Content content) {
    // use S3Service.to.sync with a custom s3path
  }

  // TODO: confirmation dialog
  void confirmDelete(S3Content content) async {
    console.info('explorerType: $explorerType');

    if (explorerType == 'picker') {
      AttachmentsScreenController.to.data.remove(content.object!.eTag);
      return;
    }

    void _delete() async {
      Get.back();
      change(true, status: RxStatus.loading());
      final result = await S3Service.to.remove(content);

      if (result.isLeft) {
        change(false, status: RxStatus.success());

        return UIUtils.showSimpleDialog(
          'Delete Failed',
          'Error: ${result.left}',
        );
      }

      NotificationsManager.notify(
        title: 'Deleted File',
        body: content.name,
      );

      change(false, status: RxStatus.success());
      await S3ExplorerScreenController.to.reload();
    }

    final dialogContent = Text(
      'Are you sure you want to delete "${content.name}"?',
    );

    Get.dialog(AlertDialog(
      title: Text('delete_file'.tr),
      content: Utils.isDrawerExpandable
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

  void askToDownload(S3Content content) {
    final dialogContent = Text('Save "${content.maskedName}" to local disk?');

    Get.dialog(AlertDialog(
      title: const Text('Download'),
      content: Utils.isDrawerExpandable
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
            _download(content);
          },
        ),
      ],
    ));
  }

  void _download(S3Content content) async {
    change(true, status: RxStatus.loading());
    final downloadPath = join(LisoPaths.temp!.path, content.name);

    final result = await S3Service.to.downloadFile(
      s3Path: content.path,
      filePath: downloadPath,
    );

    if (result.isLeft) {
      change(false, status: RxStatus.success());

      return UIUtils.showSimpleDialog(
        'Failed To Download',
        '${result.left} -> download()',
      );
    }

    // decrypt file after downloading
    File file = result.right;

    if (content.isEncrypted) {
      file = await CipherService.to.decryptFile(file);
    }

    final fileName = basename(file.path);
    Globals.timeLockEnabled = false; // temporarily disable

    if (GetPlatform.isMobile) {
      await Share.shareFiles(
        [file.path],
        subject: fileName,
        text: GetPlatform.isIOS ? null : fileName,
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
    await FileUtils.move(file, join(exportPath, fileName));

    NotificationsManager.notify(
      title: 'Downloaded',
      body: fileName,
    );

    change(false, status: RxStatus.success());
  }
}
