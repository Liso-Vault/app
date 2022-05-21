import 'dart:io';

import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/notifications/notifications.manager.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/cipher.service.dart';
import '../../../core/utils/file.util.dart';
import '../../../core/utils/globals.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/utils/utils.dart';
import '../../app/routes.dart';
import '../../wallet/wallet.service.dart';
import '../model/s3_content.model.dart';

class S3ExplorerScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => S3ExplorerScreenController());
  }
}

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

  bool get canUp => currentPath.value != rootPath;

  bool get isTimeMachine => Get.parameters['type'] == 'time_machine';

  String get rootPath =>
      isTimeMachine ? S3Service.to.historyPath : S3Service.to.filesPath;

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

    final result = await S3Service.to.fetch(
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

    S3Service.to.fetchStorageSize();
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
        title: 'Successfully Deleted',
        body: content.name,
      );

      change(false, status: RxStatus.success());
      await reload();
    }

    final dialogContent =
        Text('Are you sure you want to delete "${content.name}"?');

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

    await FileUtils.move(
      file,
      join(exportPath, fileName),
    );

    NotificationsManager.notify(
      title: 'Downloaded',
      body: fileName,
    );

    change(false, status: RxStatus.success());
  }

  void pickFile() async {
    if (S3Service.to.objectsCount >= WalletService.to.limits.files) {
      return Utils.adaptiveRouteOpen(
        name: Routes.upgrade,
        parameters: {
          'title': 'Title',
          'body': 'Maximum files limit reached',
        }, // TODO: add message
      );
    }

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

    if (fileSize > WalletService.to.limits.uploadSize) {
      change(false, status: RxStatus.success());

      return Utils.adaptiveRouteOpen(
        name: Routes.upgrade,
        parameters: {
          'message': 'Upload Size Limit Reached'
        }, // TODO: add message
      );
    }

    change(false, status: RxStatus.success());
    _upload(file);
  }

  void _upload(File file) async {
    final assumedTotal = S3Service.to.storageSize.value + await file.length();
    console.wtf(
      'assumedTotal: ${filesize(assumedTotal)}, max: ${filesize(WalletService.to.limits.uploadSize)}',
    );

    if (assumedTotal >= WalletService.to.limits.uploadSize) {
      return Utils.adaptiveRouteOpen(
        name: Routes.upgrade,
        parameters: {
          'title': 'Title',
          'body': 'Storage size limit reached',
        }, // TODO: add message
      );
    }

    change(true, status: RxStatus.loading());
    // encrypt file before uploading
    if (PersistenceService.to.fileEncryption.val) {
      file = await CipherService.to.encryptFile(file);
    }

    final result = await S3Service.to.uploadFile(
      file,
      metadata: await S3Service.to.updatedLocalMetadata(),
      s3Path: join(
        currentPath.value,
        basename(file.path),
      ).replaceAll('\\', '/'),
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

      final result = await S3Service.to.createFolder(
        name,
        s3Path: currentPath.value,
        metadata: await S3Service.to.updatedLocalMetadata(),
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
        child: Utils.isDrawerExpandable
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

  Widget leadingIcon(S3Content content) {
    if (!content.isFile) return const Icon(Iconsax.folder_open5);
    var iconData = Iconsax.document_1;
    if (content.fileType == null) return Icon(iconData);

    switch (content.fileType!) {
      case 'image':
        iconData = Iconsax.gallery;
        break;
      case 'video':
        iconData = Iconsax.play;
        break;
      case 'archive':
        iconData = Iconsax.archive;
        break;
      case 'audio':
        iconData = Iconsax.music;
        break;
      case 'code':
        iconData = Icons.code;
        break;
      case 'book':
        iconData = Iconsax.book_1;
        break;
      case 'exec':
        iconData = Iconsax.code;
        break;
      case 'web':
        iconData = Iconsax.chrome;
        break;
      case 'sheet':
        iconData = Iconsax.document_text;
        break;
      case 'text':
        iconData = Iconsax.document;
        break;
      case 'font':
        iconData = Iconsax.text_block;
        break;
    }

    return Icon(iconData);
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
}

// TODO: explorer type
enum S3ExplorerType {
  picker,
  timeMachine,
}
