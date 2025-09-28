import 'dart:io';

import 'package:app_core/globals.dart';
import 'package:app_core/services/notifications.service.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/hive.service.dart';
import 'package:liso/features/files/explorer/s3_exporer_screen.controller.dart';
import 'package:liso/features/files/storage.service.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/liso/liso.manager.dart';
import '../../../core/liso/liso_paths.dart';
import '../../../core/persistence/persistence.secret.dart';
import '../../../core/services/cipher.service.dart';
import '../../../core/utils/file.util.dart';
import '../../../core/utils/globals.dart';
import '../../attachments/attachments_screen.controller.dart';
import '../../supabase/model/object.model.dart';
import '../../supabase/supabase_functions.service.dart';

class S3ObjectTileController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  String explorerType = '';

  // PROPERTIES
  final busy = false.obs;

  // INIT
  @override
  void change(status) {
    busy.value = status.isLoading;
    super.change(status);
  }

  // FUNCTIONS
  void share(S3Object object) async {
    change(GetStatus.loading());

    final result = await AppFunctionsService.to.presignUrl(
      object: object.key,
      expirySeconds: 1.hours.inSeconds,
    );

    change(GetStatus.success(null));

    if (result.isLeft || result.right.status != 200) {
      return UIUtils.showSimpleDialog(
        'sharing_failed'.tr,
        'please_try_again_later'.tr,
      );
    }

    final dialogContent = Text(
      '${object.name} ${'will_only_be_available_to_download_for_1_hour_from_now'.tr}',
    );

    Get.dialog(AlertDialog(
      title: Text('share_securely'.tr),
      content: isSmallScreen
          ? dialogContent
          : SizedBox(width: 450, child: dialogContent),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        if (GetPlatform.isMobile) ...[
          TextButton(
            child: Text('share_url'.tr),
            onPressed: () {
              Get.backLegacy();

              SharePlus.instance.share(
                ShareParams(
                  text: result.right.data.url,
                ),
              );
            },
          ),
        ] else ...[
          TextButton(
            child: Text('copy_url'.tr),
            onPressed: () {
              Get.backLegacy();
              Utils.copyToClipboard(result.right.data.url);
            },
          ),
        ]
      ],
    ));
  }

  void confirmSwitch(S3Object object) {
    void proceed() async {
      change(GetStatus.loading());
      // purge all items
      await HiveService.to.purge();
      // download chosen vault file
      final downloadResult = await FileService.to.download(
        object: object.key,
      );

      if (downloadResult.isLeft) {
        change(GetStatus.success(null));

        return UIUtils.showSimpleDialog(
          'failed_to_download'.tr,
          '${downloadResult.left} -> download()',
        );
      }

      // re-upload to overwrite current vault file
      final uploadResult = await FileService.to.upload(
        downloadResult.right,
        object: kVaultFileName,
      );

      if (uploadResult.isLeft) {
        change(GetStatus.success(null));

        return UIUtils.showSimpleDialog(
          'upload_failed'.tr,
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

      NotificationsService.to.notify(
        title: 'successfully_switched'.tr,
        body: 'Successfully switched to vault: ${object.name}',
      );

      Get.offNamedUntil(Routes.main, (route) => false);
    }

    final dialogContent = Text(
      'Are you sure you want to switch to this version of your vault? Last modified: ${object.lastModified}',
    );

    Get.dialog(AlertDialog(
      title: Text('switch_vault'.tr),
      content: isSmallScreen
          ? dialogContent
          : SizedBox(width: 450, child: dialogContent),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          child: Text('switch'.tr),
          onPressed: () {
            Get.backLegacy();
            proceed();
          },
        ),
      ],
    ));
  }

  // TODO: confirmation dialog
  void confirmDelete(S3Object object) async {
    if (explorerType == 'picker') {
      AttachmentsScreenController.to.data.remove(object.etag);
      return;
    }

    void delete() async {
      Get.backLegacy();
      change(GetStatus.loading());
      final result = await FileService.to.remove(object.key);

      if (result.isLeft) {
        change(GetStatus.success(null));

        return UIUtils.showSimpleDialog(
          'delete_failed'.tr,
          'Error: ${result.left}',
        );
      }

      NotificationsService.to.notify(
        title: 'deleted'.tr,
        body: object.name,
      );

      change(GetStatus.success(null));
      await S3ExplorerScreenController.to.load();
    }

    final dialogContent = Text(
      'Are you sure you want to delete "${object.name}"?',
    );

    Get.dialog(AlertDialog(
      title: Text('delete'.tr),
      content: isSmallScreen
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
          onPressed: delete,
          child: Text('confirm_delete'.tr),
        ),
      ],
    ));
  }

  void confirmDownload(S3Object object) {
    void proceed() async {
      change(GetStatus.loading());
      final downloadPath = join(LisoPaths.temp!.path, object.maskedName);
      final result = await FileService.to.download(object: object.key);

      if (result.isLeft) {
        change(GetStatus.success(null));

        return UIUtils.showSimpleDialog(
          'failed_to_download'.tr,
          '${result.left} -> download()',
        );
      }

      // decrypt file after downloading
      var file = File(downloadPath);

      await file.writeAsBytes(object.isEncrypted
          ? CipherService.to.decrypt(result.right)
          : result.right);

      final fileName = basename(file.path);

      timeLockEnabled = false; // temporarily disable

      if (GetPlatform.isMobile) {
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: fileName,
          text: GetPlatform.isIOS ? null : fileName,
        );

        timeLockEnabled = true; // re-enable
        return change(GetStatus.success(null));
      }

      // choose directory and export file
      final exportPath = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'choose_export_path'.tr,
      );

      timeLockEnabled = true; // re-enable
      // user cancelled picker
      if (exportPath == null) {
        return change(GetStatus.success(null));
      }

      console.info('export path: $exportPath');
      await Future.delayed(1.seconds); // just for style
      await FileUtils.move(file, join(exportPath, fileName));

      NotificationsService.to.notify(
        title: 'downloaded'.tr,
        body: fileName,
      );

      change(GetStatus.success(null));
    }

    final dialogContent = Text('Save "${object.maskedName}" to local disk?');

    Get.dialog(AlertDialog(
      title: Text('download'.tr),
      content: isSmallScreen
          ? dialogContent
          : SizedBox(width: 450, child: dialogContent),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          child: Text('download'.tr),
          onPressed: () {
            Get.backLegacy();
            proceed();
          },
        ),
      ],
    ));
  }
}
