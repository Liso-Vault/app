import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/notifications/notifications.manager.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:path/path.dart';

import '../../core/services/local_auth.service.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/ui_utils.dart';
import '../app/routes.dart';

const kSourceFormats = [
  'Bitwarden (json)',
  'Chrome (csv)',
  '1Password (csv)',
  'LastPass (csv)',
];

class ImportScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final filePathController = TextEditingController();
  String source = kSourceFormats.first;

  // PROPERTIES
  final busy = false.obs;

  // GETTERS

  Future<bool> get canPop async => !busy.value;

  // INIT
  @override
  void onInit() {
    change('', status: RxStatus.success());
    super.onInit();
  }

  @override
  void change(newState, {RxStatus? status}) {
    busy.value = status?.isLoading ?? false;
    super.change(newState, status: status);
  }

  // FUNCTIONS

  Future<void> continuePressed() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    if (!formKey.currentState!.validate()) return;
    change(null, status: RxStatus.loading());

    Future<void> _proceed() async {
      final authenticated = await LocalAuthService.to.authenticate();
      if (!authenticated) return;
      // do the actual import

      const itemCount = 0; // TODO: replace this later
      
      MainScreenController.to.load();

      NotificationsManager.notify(
        title: 'Import Successful',
        body: 'Successfully imported $itemCount items',
      );

      Get.offNamedUntil(Routes.main, (route) => false);
    }

    await UIUtils.showImageDialog(
      Icon(Iconsax.import, size: 100, color: themeColor),
      title: 'Import Items',
      subTitle: basename(filePathController.text),
      body:
          "Are you sure you want to import the items on this file to your vault?",
      action: _proceed,
      actionText: 'Restore',
      closeText: 'Cancel',
      onClose: () {
        change(null, status: RxStatus.success());
        Get.back();
      },
    );
  }

  void importFile() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    if (GetPlatform.isAndroid) FilePicker.platform.clearTemporaryFiles();
    change(null, status: RxStatus.loading());

    Globals.timeLockEnabled = false; // disable
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
    } catch (e) {
      Globals.timeLockEnabled = true; // re-enable
      console.error('FilePicker error: $e');
      return;
    }

    change(null, status: RxStatus.success());

    if (result == null || result.files.isEmpty) {
      Globals.timeLockEnabled = true; // re-enable
      console.warning("canceled file picker");
      return;
    }

    final validExtensions = ['.json', '.csv', '.xml'];

    final isValidExtension = validExtensions.contains(
      extension(result.files.single.path!),
    );

    if (!isValidExtension) {
      return UIUtils.showSimpleDialog(
        'Invalid Exported File',
        'Allowed file extensions are ${validExtensions.join(',')}',
      );
    }

    filePathController.text = result.files.single.path!;
  }
}
