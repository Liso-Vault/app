import 'dart:io';

import 'package:console_mixin/console_mixin.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/features/import/importers/bitwarden.importer.dart';
import 'package:liso/features/import/importers/chrome.importer.dart';
import 'package:path/path.dart';

import '../../core/utils/globals.dart';
import '../../core/utils/ui_utils.dart';
import '../groups/groups.controller.dart';
import 'importers/lastpass.importer.dart';

class ExportedSourceFormat {
  final String name;
  final String extension;

  ExportedSourceFormat(this.name, this.extension);

  String get id => '${name.toLowerCase()}-$extension';
  String get title => '$name ($extension)';
}

final sourceFormats = [
  ExportedSourceFormat('Bitwarden', 'json'),
  ExportedSourceFormat('Bitwarden', 'csv'),
  ExportedSourceFormat('Chrome', 'csv'),
  ExportedSourceFormat('LastPass', 'csv'),
];

const kAllowedExtensions = ['json', 'csv', 'xml'];

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

    if (formatId == 'bitwarden-csv') {
      success = await BitwardenImporter.importCSV(contents);
    } else if (formatId == 'chrome-csv') {
      success = await ChromeImporter.importCSV(contents);
    } else if (formatId == 'lastpass-csv') {
      success = await LastPassImporter.importCSV(contents);
    }

    console.info('success csv import: $success');
    change(null, status: RxStatus.success());
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

    await UIUtils.showImageDialog(
      Icon(Iconsax.import, size: 100, color: themeColor),
      title: 'Import Items',
      subTitle: basename(filePathController.text),
      body:
          "Are you sure you want to import the items from this exported file to your vault?",
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

    Globals.timeLockEnabled = false; // disable
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: kAllowedExtensions,
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
