import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/form_field.util.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/utils/console.dart';

import '../../core/hive/hive.manager.dart';
import '../../core/hive/models/metadata/metadata.hive.dart';
import '../../core/parsers/template.parser.dart';
import '../general/custom_dialog.widget.dart';
import '../general/selector.sheet.dart';

class ItemScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ItemScreenController());
  }
}

class ItemScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  // VARIABLES
  HiveLisoItem? item;

  final formKey = GlobalKey<FormState>();
  final mode = Get.parameters['mode'] as String;
  final category = Get.parameters['category'] as String;
  final titleController = TextEditingController();
  final tagsController = TextEditingController();

  List<String> tags = [];

  // parse fields to actual widgets
  final widgets = <Widget>[].obs;
  final icon = Uint8List(0).obs;

  // PROPERTIES
  final favorite = false.obs;

  // GETTERS

  // INIT

  @override
  void onInit() async {
    if (mode == 'add') {
      await _loadTemplate();
    } else if (mode == 'update') {
      final hiveKey = Get.parameters['hiveKey'].toString();
      item = HiveManager.items!.get(int.parse(hiveKey));
      icon.value = item!.icon;
      titleController.text = item!.title;
      favorite.value = item!.favorite;
      tags = item!.tags;
    }

    widgets.value = item!.widgets;
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

  Future<void> _loadTemplate() async {
    item = HiveLisoItem(
      category: category,
      icon: Uint8List(0),
      title: '',
      fields: TemplateParser.parse(category),
      tags: [],
      metadata: await HiveMetadata.get(),
    );
  }

  void add() async {
    if (!formKey.currentState!.validate()) return;

    final newItem = HiveLisoItem(
      category: category,
      icon: icon.value,
      title: titleController.text,
      tags: tags,
      fields: FormFieldUtils.obtainFields(item!, widgets: widgets),
      metadata: await HiveMetadata.get(),
    );

    await HiveManager.items!.add(newItem);
    Get.back();
  }

  void edit() async {
    if (!formKey.currentState!.validate()) return;
    if (item == null) return;

    item!.icon = icon.value;
    item!.title = titleController.text;
    item!.fields = FormFieldUtils.obtainFields(item!, widgets: widgets);
    item!.tags = tags;
    item!.favorite = favorite.value;
    item!.metadata = await item!.metadata.getUpdated();
    await item!.save();

    Get.back();
  }

  void trash() {
    void _proceed() async {
      await item?.delete();
      Get.back();
    }

    SelectorSheet(
      items: [
        SelectorItem(
          title: 'Move to trash',
          leading: const Icon(LineIcons.exclamationTriangle, color: Colors.red),
          onSelected: _proceed,
        ),
        SelectorItem(
          title: 'Cancel',
          leading: const Icon(LineIcons.timesCircle),
          onSelected: Get.back,
        ),
      ],
    ).show();
  }

  List<String> querySuggestions(String query) {
    if (query.isEmpty) return [];

    final _usedTags = HiveManager.items!.values
        .map((e) => e.tags.where((x) => x.isNotEmpty).toList())
        .toSet();

    // include query as a suggested tag
    final Set<String> _tags = {query};

    if (_usedTags.isNotEmpty) {
      _tags.addAll(_usedTags.reduce((a, b) => a + b).toSet());
    }

    final filteredTags = _tags.where((e) => e.contains(query));
    return filteredTags.toList();
  }

  void querySubmitted() {
    // TODO: add tag when submitted
    // tags.add(tagsController.text);
  }

  void changeIcon() async {
    SelectorSheet(
      title: 'Item Icon',
      items: [
        SelectorItem(
          title: 'change'.tr,
          leading: const Icon(LineIcons.image),
          onSelected: _pickIcon,
        ),
        SelectorItem(
          title: 'remove'.tr,
          leading: const Icon(LineIcons.trash),
          onSelected: () => icon.value = Uint8List(0),
        ),
      ],
    ).show();
  }

  void _pickIcon() async {
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowedExtensions: ['png', 'jpg'],
      );
    } catch (e) {
      return console.error('FilePicker error: $e');
    }

    if (result == null || result.files.isEmpty) {
      return console.warning("canceled FilePicker");
    }

    final image = result.files.single;

    final file = File(image.path!);
    if (!await file.exists()) return console.warning("doesn't exist");

    // 500kb
    if (await file.length() > 500000) {
      Get.generalDialog(
        pageBuilder: (_, __, ___) => AlertDialog(
          title: const Text('Image Too Large'),
          content: const Text(
              'Please choose an image with size not larger than 500kb'),
          actions: [
            TextButton(
              child: const Text('Okay'),
              onPressed: Get.back,
            ),
          ],
        ),
      );

      return console.warning("too large");
    }

    icon.value = await file.readAsBytes();
  }
}
