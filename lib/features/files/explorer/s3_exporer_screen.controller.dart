import 'dart:io';

import 'package:app_core/globals.dart';
import 'package:app_core/services/notifications.service.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:liso/core/persistence/persistence.secret.dart';
import 'package:liso/features/files/storage.service.dart';
import 'package:liso/features/files/sync.service.dart';
import 'package:path/path.dart';

import '../../../core/services/cipher.service.dart';
import '../../../core/utils/globals.dart';
import '../../../core/utils/utils.dart';
import '../../config/license.model.dart';
import '../../supabase/model/object.model.dart';

class S3ExplorerScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static S3ExplorerScreenController get to => Get.find();

  // VARIABLES
  final storage = Get.find<FileService>();
  String rootPrefix = '';

  // PROPERTIES
  final data = <S3Object>[].obs;
  final currentPrefix = ''.obs;
  final busy = false.obs;

  // PROPERTIES

  // GETTERS
  bool get isRoot => currentPrefix.value == rootPrefix;
  bool get isTimeMachine => gParameters['type'] == 'time_machine';
  bool get isPicker => gParameters['type'] == 'picker';
  String get rootFolderName => isTimeMachine ? kDirBackups : kDirFiles;

  // INIT
  @override
  void onInit() {
    rootPrefix = '${SecretPersistence.to.walletAddress.val}/$rootFolderName/';
    currentPrefix.value = rootPrefix;
    navigate(prefix: currentPrefix.value);
    super.onInit();
  }

  @override
  void change(status) {
    busy.value = status.isLoading;
    super.change(status);
  }

  // FUNCTIONS

  Future<void> load({bool pulled = false}) async {
    if (!pulled) change(GetStatus.loading());
    await storage.load();
    navigate(prefix: currentPrefix.value);
  }

  void navigate({required String prefix}) async {
    List<S3Object> objects = List.from(storage.rootInfo.value.data.objects);

    objects = objects.where((e) {
      final currentPath = e.key.replaceAll(prefix, '');
      final isFolder = '/'.allMatches(currentPath).length == 1 && !e.isFile;
      final isFile = '/'.allMatches(currentPath).isEmpty && e.isFile;

      return e.key != prefix &&
          e.key.startsWith(prefix) &&
          (isFolder || isFile);
    }).toList();

    data.clear();
    await Future.delayed(100.milliseconds);
    data.value = objects;
    currentPrefix.value = prefix;

    change(
      data.isEmpty ? GetStatus.empty() : GetStatus.success(null),
    );
  }

  void up() {
    final prefix = currentPrefix.value.split('/');
    prefix.removeLast();
    prefix.removeLast();
    navigate(prefix: '${prefix.join('/')}/');
  }

  void pickFile() async {
    change(GetStatus.loading());
    timeLockEnabled = false; // disable
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
    } catch (e) {
      timeLockEnabled = true; // re-enable
      console.error('FilePicker error: $e');
      change(GetStatus.success(null));
      return;
    }

    if (result == null || result.files.isEmpty) {
      timeLockEnabled = true; // re-enable
      console.warning("canceled file picker");
      change(GetStatus.success(null));
      return;
    }

    timeLockEnabled = true; // re-enable
    final file = File(result.files.single.path!);
    console.info('picked: ${file.path}');

    int fileSize = 0;

    try {
      fileSize = await file.length();
    } catch (e) {
      change(GetStatus.success(null));

      return UIUtils.showSimpleDialog(
        'file_size_error'.tr,
        'Cannot retrieve file size: $e',
      );
    }

    if (fileSize > limits.uploadSize) {
      change(GetStatus.success(null));

      return Utils.adaptiveRouteOpen(
        name: Routes.upgrade,
        parameters: {
          'title': 'upload_large_files'.tr,
          'body':
              'Upload size limit: ${filesize(limits.uploadSize)} reached. Upgrade to Pro to upload up to ${filesize(licenseConfig.pro.uploadSize)} per file.',
        },
      );
    }

    change(GetStatus.success(null));
    _upload(file);
  }

  void _upload(File file) async {
    final assumedTotal = storage.rootInfo.value.data.size + await file.length();

    if (assumedTotal >= limits.uploadSize) {
      return Utils.adaptiveRouteOpen(
        name: Routes.upgrade,
        parameters: {
          'title': 'add_more_storage'.tr,
          'body':
              'Upgrade to Pro to store up to ${filesize(licenseConfig.pro.storageSize)} of files.',
        },
      );
    }

    change(GetStatus.loading());
    final encryptedBytes = CipherService.to.encrypt(await file.readAsBytes());
    final fileName = basename(file.path) + kEncryptedExtensionExtra;

    final result = await storage.upload(
      encryptedBytes,
      object: '${currentPrefix.value}$fileName',
    );

    if (result.isLeft) {
      change(GetStatus.success(null));

      return UIUtils.showSimpleDialog(
        'upload_failed'.tr,
        'Error: ${result.left}',
      );
    }

    NotificationsService.to.notify(
      title: 'successfully_uploaded'.tr,
      body: fileName,
    );

    change(GetStatus.success(null));
    await load();
  }

  void newFolder() async {
    final formKey = GlobalKey<FormState>();
    final folderController = TextEditingController();

    void createDirectory(String name) async {
      if (!formKey.currentState!.validate()) return;
      change(GetStatus.loading());

      // TODO: check if folder already exists
      final result = await storage.upload(
        Uint8List(0),
        object: '${currentPrefix.value}$name/',
      );

      if (result.isLeft) {
        change(GetStatus.success(null));

        return UIUtils.showSimpleDialog(
          'create_folder_failed'.tr,
          'Error: ${result.left}',
        );
      }

      NotificationsService.to.notify(
        title: 'folder_created'.tr,
        body: folderController.text,
      );

      change(GetStatus.success(null));
      await load();
    }

    final content = TextFormField(
      controller: folderController,
      autofocus: true,
      textCapitalization: TextCapitalization.sentences,
      maxLength: 100,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (data) => AppUtils.validateFolderName(data!),
      decoration: InputDecoration(
        labelText: 'name'.tr,
        hintText: 'folder_name'.tr,
      ),
    );

    Get.dialog(AlertDialog(
      title: Text('new_folder'.tr),
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
          child: Text('create'.tr),
          onPressed: () {
            final exists = data
                .where((e) => !e.isFile && e.name == folderController.text)
                .isNotEmpty;

            if (!exists) {
              Get.backLegacy();
              createDirectory(folderController.text);
            } else {
              UIUtils.showSimpleDialog(
                'folder_already_exists'.tr,
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
