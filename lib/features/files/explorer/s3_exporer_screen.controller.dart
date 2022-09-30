import 'dart:io';

import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/notifications/notifications.manager.dart';
import 'package:liso/features/files/storage.service.dart';
import 'package:liso/features/files/sync.service.dart';
import 'package:path/path.dart';

import '../../../core/services/cipher.service.dart';
import '../../../core/utils/globals.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/utils/utils.dart';
import '../../app/routes.dart';
import '../../menu/menu.item.dart';
import '../../pro/pro.controller.dart';
import '../model/s3_content.model.dart';

class S3ExplorerScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static S3ExplorerScreenController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final data = <S3Content>[].obs;
  final currentPath = ''.obs;
  final busy = false.obs;

  // PROPERTIES

  // GETTERS
  bool get isInRoot => currentPath.value == rootPath;
  bool get isTimeMachine => Get.parameters['type'] == 'time_machine';
  bool get isPicker => Get.parameters['type'] == 'picker';

  String get rootPath => isTimeMachine
      ? '${SyncService.to.backupsPath}/'
      : SyncService.to.filesPath;

  List<ContextMenuItem> get menuItemsUploadType {
    return [
      ContextMenuItem(
        title: 'File',
        leading: const Icon(Iconsax.document_upload),
        onSelected: pickFile,
      ),
      ContextMenuItem(
        title: 'Encrypted File',
        leading: const Icon(Iconsax.shield_tick),
        onSelected: () => pickFile(encryptFile: true),
      ),
    ];
  }

  // INIT
  @override
  void onInit() {
    load(path: rootPath);
    super.onInit();
  }

  @override
  void change(newState, {RxStatus? status}) {
    busy.value = status?.isLoading ?? false;
    super.change(newState, status: status);
  }

  // FUNCTIONS
  Future<void> pulledRefresh() async {
    await load(path: currentPath.value, pulled: true);
  }

  Future<void> reload() async => await load(path: currentPath.value);

  Future<void> up() async => await load(path: '${dirname(currentPath.value)}/');

  Future<void> load({
    required String path,
    bool pulled = false,
  }) async {
    if (!pulled) change(true, status: RxStatus.loading());

    final result = await StorageService.to.fetch(
      path: path,
      filterExtensions: isTimeMachine ? ['.$kVaultExtension'] : [],
    );

    result.either(
      (error) {
        UIUtils.showSimpleDialog(
          'Fetch Error',
          '$error -> load()',
        );

        change(false, status: RxStatus.success());
      },
      (response) {
        data.value = response;
        currentPath.value = path;

        change(
          false,
          status: data.isEmpty ? RxStatus.empty() : RxStatus.success(),
        );
      },
    );

    StorageService.to.init();
  }

  void pickFile({bool encryptFile = false}) async {
    change(true, status: RxStatus.loading());
    Globals.timeLockEnabled = false; // disable
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
    } catch (e) {
      Globals.timeLockEnabled = true; // re-enable
      console.error('FilePicker error: $e');
      change(false, status: RxStatus.success());
      return;
    }

    if (result == null || result.files.isEmpty) {
      Globals.timeLockEnabled = true; // re-enable
      console.warning("canceled file picker");
      change(false, status: RxStatus.success());
      return;
    }

    Globals.timeLockEnabled = true; // re-enable
    final file = File(result.files.single.path!);
    console.info('picked: ${file.path}');

    int fileSize = 0;

    try {
      fileSize = await file.length();
    } catch (e) {
      change(false, status: RxStatus.success());

      return UIUtils.showSimpleDialog(
        'File Size Error',
        'Cannot retrieve file size: $e',
      );
    }

    if (fileSize > ProController.to.limits.uploadSize) {
      change(false, status: RxStatus.success());

      return Utils.adaptiveRouteOpen(
        name: Routes.upgrade,
        parameters: {
          'title': 'Upload Large Files',
          'body':
              'Upload size limit: ${filesize(ProController.to.limits.uploadSize)} reached. Upgrade to Pro to upload up to ${filesize(ConfigService.to.limits.pro.uploadSize)} per file.',
        },
      );
    }

    change(false, status: RxStatus.success());
    _upload(file, encryptFile: encryptFile);
  }

  void _upload(File file, {bool encryptFile = false}) async {
    final assumedTotal =
        StorageService.to.rootInfo.value.data.size + await file.length();

    if (assumedTotal >= ProController.to.limits.uploadSize) {
      return Utils.adaptiveRouteOpen(
        name: Routes.upgrade,
        parameters: {
          'title': 'Add More Storage',
          'body':
              'Upgrade to Pro to store up to ${filesize(ConfigService.to.limits.pro.storageSize)} of files.',
        },
      );
    }

    change(true, status: RxStatus.loading());
    // encrypt file before uploading
    if (encryptFile) {
      file = await CipherService.to.encryptFile(file);
    }

    final result = await StorageService.to.upload(
      await file.readAsBytes(),
      object: '${currentPath.value}/${basename(file.path)}',
    );

    if (result.isLeft) {
      change(false, status: RxStatus.success());

      return UIUtils.showSimpleDialog(
        'Upload Failed',
        'Error: ${result.left}',
      );
    }

    NotificationsManager.notify(
      title: 'Successfully Uploaded',
      body: basename(file.path),
    );

    change(false, status: RxStatus.success());
    await reload();
  }

  void newFolder() async {
    final formKey = GlobalKey<FormState>();
    final folderController = TextEditingController();

    void _createDirectory(String name) async {
      if (!formKey.currentState!.validate()) return;
      // TODO: check if folder already exists
      change(true, status: RxStatus.loading());

      final result = await StorageService.to.createFolder(
        name,
        s3Path: currentPath.value,
      );

      if (result.isLeft) {
        change(false, status: RxStatus.success());

        return UIUtils.showSimpleDialog(
          'Create Folder Failed',
          'Error: ${result.left}',
        );
      }

      NotificationsManager.notify(
        title: 'Folder Created',
        body: folderController.text,
      );

      change(false, status: RxStatus.success());
      await reload();
    }

    final content = TextFormField(
      controller: folderController,
      autofocus: true,
      textCapitalization: TextCapitalization.sentences,
      maxLength: 100,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (data) => Utils.validateFolderName(data!),
      decoration: const InputDecoration(
        labelText: 'Name',
        hintText: 'Folder Name',
      ),
    );

    Get.dialog(AlertDialog(
      title: Text('new_folder'.tr),
      content: Form(
        key: formKey,
        child: Utils.isSmallScreen
            ? content
            : SizedBox(width: 450, child: content),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          child: Text('create'.tr),
          onPressed: () {
            final exists = data
                .where((e) => !e.isFile && e.name == folderController.text)
                .isNotEmpty;

            if (!exists) {
              Get.back();
              _createDirectory(folderController.text);
            } else {
              UIUtils.showSimpleDialog(
                'Folder Already Exists',
                '"${folderController.text}" already exists.',
              );
            }
          },
        ),
      ],
    ));
  }
}

// TODO: explorer type
enum S3ExplorerType {
  picker,
  timeMachine,
}
