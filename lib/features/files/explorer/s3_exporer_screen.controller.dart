import 'dart:io';

import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/notifications/notifications.manager.dart';
import 'package:liso/core/persistence/persistence.secret.dart';
import 'package:liso/features/files/storage.service.dart';
import 'package:liso/features/files/sync.service.dart';
import 'package:path/path.dart';

import '../../../core/services/cipher.service.dart';
import '../../../core/supabase/model/object.model.dart';
import '../../../core/utils/globals.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/utils/utils.dart';
import '../../app/routes.dart';
import '../../pro/pro.controller.dart';

class S3ExplorerScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static S3ExplorerScreenController get to => Get.find();

  // VARIABLES
  final storage = Get.find<StorageService>();
  String rootPrefix = '';

  // PROPERTIES
  final data = <S3Object>[].obs;
  final currentPrefix = ''.obs;
  final busy = false.obs;

  // PROPERTIES

  // GETTERS
  bool get isRoot => currentPrefix.value == rootPrefix;
  bool get isTimeMachine => Get.parameters['type'] == 'time_machine';
  bool get isPicker => Get.parameters['type'] == 'picker';
  String get rootFolderName => isTimeMachine ? kDirBackups : kDirFiles;

  // INIT
  @override
  void onInit() {
    rootPrefix = '${SecretPersistence.to.longAddress}/$rootFolderName/';
    navigate(prefix: rootPrefix);
    super.onInit();
  }

  @override
  void change(newState, {RxStatus? status}) {
    busy.value = status?.isLoading ?? false;
    super.change(newState, status: status);
  }

  // FUNCTIONS

  void up() {
    final prefix = currentPrefix.value.split('/');
    prefix.removeLast();
    prefix.removeLast();

    navigate(prefix: '${prefix.join('/')}/');
  }

  void navigate({required String prefix}) async {
    List<S3Object> objects = List.from(storage.rootInfo.value.data.objects);

    objects = objects.where((e) {
      final path = e.key.replaceAll(prefix, '');
      final isFolder = '/'.allMatches(path).length == 1 && !e.isFile;
      final isFile = '/'.allMatches(path).isEmpty && e.isFile;

      return e.key != prefix &&
          e.key.startsWith(prefix) &&
          (isFolder || isFile);
    }).toList();

    data.clear();
    await Future.delayed(100.milliseconds);
    data.value = objects;
    currentPrefix.value = prefix;

    change(
      null,
      status: data.isEmpty ? RxStatus.empty() : RxStatus.success(),
    );
  }

  Future<void> load({bool pulled = false}) async {
    if (!pulled) change(true, status: RxStatus.loading());
    await storage.load();
    navigate(prefix: currentPrefix.value);
  }

  void pickFile() async {
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
    _upload(file);
  }

  void _upload(File file) async {
    final assumedTotal = storage.rootInfo.value.data.size + await file.length();

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
    final encryptedBytes = CipherService.to.encrypt(await file.readAsBytes());
    final fileName = basename(file.path) + kEncryptedExtensionExtra;

    final result = await storage.upload(
      encryptedBytes,
      object: '${currentPrefix.value}$fileName',
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
      body: fileName,
    );

    change(false, status: RxStatus.success());
    await load();
  }

  void newFolder() async {
    final formKey = GlobalKey<FormState>();
    final folderController = TextEditingController();

    void createDirectory(String name) async {
      if (!formKey.currentState!.validate()) return;
      change(true, status: RxStatus.loading());

      // TODO: check if folder already exists
      final result = await storage.upload(
        Uint8List(0),
        object: '${currentPrefix.value}$name/',
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
      await load();
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
              createDirectory(folderController.text);
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
