import 'dart:io';

import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/features/drawer/drawer_widget.controller.dart';
import 'package:liso/features/import/importers/bitwarden.importer.dart';
import 'package:liso/features/import/importers/chrome.importer.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:path/path.dart';

import '../../core/utils/globals.dart';
import '../groups/groups.controller.dart';
import 'importers/apple.importer.dart';
import 'importers/firefox.importer.dart';
import 'importers/lastpass.importer.dart';
import 'importers/nordpass.importer.dart';

class ExportedSourceFormat {
  final String name;
  final String extension;

  ExportedSourceFormat(this.name, this.extension);

  String get id => '${name.toLowerCase()}-$extension';
  String get title => '$name ($extension)';
}

final sourceFormats = [
  ExportedSourceFormat('Apple', 'csv'),
  ExportedSourceFormat('Chrome', 'csv'),
  ExportedSourceFormat('Bitwarden', 'csv'),
  ExportedSourceFormat('LastPass', 'csv'),
  // ExportedSourceFormat('NordPass', 'csv'),
  ExportedSourceFormat('Brave', 'csv'),
  ExportedSourceFormat('Opera', 'csv'),
  ExportedSourceFormat('Edge', 'csv'),
  ExportedSourceFormat('Firefox', 'csv'),
];

const kAllowedExtensions = ['json', 'csv', 'xml'];

const kSmartGroupId = 'smart-destination-vault';

class ImportScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static ImportScreenController get to => Get.find();

  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final filePathController = TextEditingController();
  final sourceFormat = sourceFormats.first.obs;
  final destinationGroupId = GroupsController.to.combined.first.id.obs;

  // PROPERTIES
  final busy = false.obs;
  final autoTag = true.obs;

  // GETTERS

  Future<bool> get canPop async => !busy.value;

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

  void _importCSV(String contents) async {
    final formatId = sourceFormat.value.id;
    bool success = false;

    const chromeBasedFormats = [
      'chrome-csv',
      'brave-csv',
      'opera-csv',
      'edge-csv'
    ];

    if (formatId == 'bitwarden-csv') {
      success = await BitwardenImporter.importCSV(contents);
    } else if (chromeBasedFormats.contains(formatId)) {
      success = await ChromeImporter.importCSV(contents);
    } else if (formatId == 'lastpass-csv') {
      success = await LastPassImporter.importCSV(contents);
    } else if (formatId == 'apple-csv') {
      success = await AppleImporter.importCSV(contents);
    } else if (formatId == 'firefox-csv') {
      success = await FirefoxImporter.importCSV(contents);
    } else if (formatId == 'nordpass-csv') {
      success = await NordPassImporter.importCSV(contents);
    }

    console.info('success csv import: $success');
    change(null, status: RxStatus.success());

    if (success) {
      DrawerMenuController.to.clearFilters();
      DrawerMenuController.to.filterGroupId.value = ''; // all
      MainScreenController.to.load();
      Get.offNamedUntil(Routes.main, (route) => false);
    }
  }

  void _importJSON(String contents) {
    //

    change(null, status: RxStatus.success());
  }

  void _importXML(String contents) {
    //

    change(null, status: RxStatus.success());
  }

  Future<void> _proceed() async {
    final file = File(filePathController.text);

    if (!(await file.exists())) {
      Get.back();

      return UIUtils.showSimpleDialog(
        'File Not Found',
        'Please make sure the file: ${file.path} exists.',
      );
    }

    final fileExtension = extension(file.path);

    if (fileExtension != '.${sourceFormat.value.extension}') {
      Get.back();

      return UIUtils.showSimpleDialog(
        'Incorrect File Format',
        'Import the correct file with format: ${sourceFormat.value.title}',
      );
    }

    change(null, status: RxStatus.loading());
    // create a backup
    await LisoManager.createBackup();
    // if recently imported and trying to import again, cancel previous chance to undo
    MainScreenController.to.importedItemIds.clear();
    // read contents of file
    final contents = await file.readAsString();
    // catch empty exported file
    if (contents.isEmpty) {
      Get.back();

      return UIUtils.showSimpleDialog(
        'Empty File',
        'Please import a valid exported file',
      );
    }

    // close confirm dialog
    Get.back();

    if (extension(file.path) == '.json') {
      _importJSON(contents);
    } else if (extension(file.path) == '.csv') {
      _importCSV(contents);
    } else if (extension(file.path) == '.xml') {
      _importXML(contents);
    }
  }

  Future<void> continuePressed() async {
    if (status == RxStatus.loading()) return console.error('still busy');
    if (!formKey.currentState!.validate()) return;

    String body = "";

    if (sourceFormat.value.id == 'bitwarden-csv') {
      body =
          "Please note that importing a ${sourceFormat.value.title} file doesn't include non-login types.\n\n";
    } else if (sourceFormat.value.id == 'lastpass-csv') {
      body =
          "Please note that importing a ${sourceFormat.value.title} file doesn't include (password prompt / protected item) settings.\n\n";
    }

    body +=
        "Are you sure you want to import the items from this exported ${sourceFormat.value.title} file to your vault?";

    await UIUtils.showImageDialog(
      Icon(Iconsax.import_outline, size: 100, color: themeColor),
      title: 'Import Items',
      subTitle: basename(filePathController.text),
      body: body,
      action: _proceed,
      actionText: 'Import',
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

    timeLockEnabled = false; // disable
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: kAllowedExtensions,
      );
    } catch (e) {
      timeLockEnabled = true; // re-enable
      console.error('FilePicker error: $e');
      return;
    }

    change(null, status: RxStatus.success());

    if (result == null || result.files.isEmpty) {
      timeLockEnabled = true; // re-enable
      console.warning("canceled file picker");
      return;
    }

    final fileExtension = extension(result.files.single.path!);

    if (!kAllowedExtensions.contains(fileExtension.replaceAll('.', ''))) {
      return UIUtils.showSimpleDialog(
        'Invalid File Extension',
        'Allowed file extensions are ${kAllowedExtensions.join(',')}',
      );
    }

    filePathController.text = result.files.single.path!;
  }
}
