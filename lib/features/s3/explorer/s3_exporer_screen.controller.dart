import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/notifications/notifications.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/firebase/config/config.service.dart';
import '../../../core/utils/file.util.dart';
import '../../../core/utils/globals.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/utils/utils.dart';
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
    if (newState != null) busy.value = newState;
    super.change(newState, status: status);
  }

  // FUNCTIONS
  Future<void> pulledRefresh() async {
    await load(path: currentPath.value, pulled: true);
  }

  Future<void> reload() async => await load(path: currentPath.value);

  Future<void> up() async => await load(path: dirname(currentPath.value) + '/');

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

    final _content = Text('Are you sure you want to delete "${content.name}"?');

    Get.dialog(AlertDialog(
      title: const Text('Delete File'),
      content: Utils.isDrawerExpandable
          ? _content
          : SizedBox(
              width: 600,
              child: _content,
            ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: Get.back,
        ),
        TextButton(
          child: const Text('Confirm Delete'),
          onPressed: _delete,
        ),
      ],
    ));
  }

  void download(S3Content content) async {
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

    if (GetPlatform.isMobile) {
      await Share.shareFiles(
        [downloadPath],
        subject: content.name,
        text: GetPlatform.isIOS ? null : content.name,
      );

      return change(false, status: RxStatus.success());
    }

    Globals.timeLockEnabled = false; // temporarily disable
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
      result.right,
      join(exportPath, content.name),
    );

    NotificationsManager.notify(
      title: 'Downloaded File',
      body: content.name,
    );

    change(false, status: RxStatus.success());
  }

  // TODO: max upload size
  void pickFile() async {
    change(true, status: RxStatus.loading());
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
    } catch (e) {
      console.error('FilePicker error: $e');
      change(false, status: RxStatus.success());
      return;
    }

    if (result == null || result.files.isEmpty) {
      console.warning("canceled file picker");
      change(false, status: RxStatus.success());
      return;
    }

    console.info('picked: ${result.files.single.path!}');
    final file = File(result.files.single.path!);

    if (await file.length() > ConfigService.to.app.settings.maxUploadSize) {
      change(false, status: RxStatus.success());

      return UIUtils.showSimpleDialog(
        'File Too Large',
        'Upload size limit is ${filesize(ConfigService.to.app.settings.maxUploadSize)} per file',
      );
    }

    _upload(file);
  }

  void _upload(File file) async {
    change(true, status: RxStatus.loading());

    final result = await S3Service.to.uploadFile(
      file,
      s3Path: join(currentPath.value, basename(file.path)),
      metadata: await S3Service.to.updatedLocalMetadata(),
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
      title: const Text('New Folder'),
      content: Form(
        key: formKey,
        child: Utils.isDrawerExpandable
            ? content
            : SizedBox(width: 600, child: content),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: Get.back,
        ),
        TextButton(
          child: const Text('Create'),
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
