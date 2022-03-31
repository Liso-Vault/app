import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/form_fields/form_field.util.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/utils/console.dart';

import '../../core/hive/hive.manager.dart';
import '../../core/hive/models/metadata/metadata.hive.dart';
import '../../core/parsers/template.parser.dart';
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
  final type = Get.parameters['type'] as String;
  final titleController = TextEditingController();
  final tagsController = TextEditingController();

  // parse fields to actual widgets
  final widgets = <Widget>[].obs;

  // PROPERTIES

  // GETTERS

  // INIT

  @override
  void onInit() async {
    if (mode == 'add') {
      await _loadTemplate();
    } else if (mode == 'update') {
      final hiveKey = Get.parameters['hiveKey'].toString();
      item = HiveManager.items!.get(int.parse(hiveKey));
      titleController.text = item!.title;
      tagsController.text = item!.tags.join(',');
    }

    widgets.value = item!.widgets;
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

  Future<void> _loadTemplate() async {
    item = HiveLisoItem(
      type: type,
      icon: Uint8List.fromList(''.codeUnits), // TODO: update icon
      title: '',
      fields: TemplateParser.parse(type),
      tags: [],
      metadata: await HiveMetadata.get(),
    );
  }

  void add() async {
    if (!formKey.currentState!.validate()) return;

    final newItem = HiveLisoItem(
      type: type,
      icon: Uint8List.fromList(''.codeUnits), // TODO: update icon
      title: titleController.text,
      tags: tagsController.text.split(','),
      fields: FormFieldUtils.obtainFields(item!, widgets: widgets),
      metadata: await HiveMetadata.get(),
    );

    await HiveManager.items!.add(newItem);
    Get.back();
  }

  void edit() async {
    if (!formKey.currentState!.validate()) return;
    if (item == null) return;

    // item!.icon = ''; // TODO: update icon
    item!.title = titleController.text;
    item!.fields = FormFieldUtils.obtainFields(item!, widgets: widgets);
    item!.tags = tagsController.text.split(',');
    item!.metadata = await item!.metadata.getUpdated();
    await item!.save();

    Get.back();
  }

  void delete() {
    void _proceed() async {
      await item?.delete();
      Get.back();
    }

    SelectorSheet(
      items: [
        SelectorItem(
          title: 'Delete',
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
}
