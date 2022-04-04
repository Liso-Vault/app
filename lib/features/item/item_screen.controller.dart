import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/form_field.util.dart';
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
  final category = Get.parameters['category'] as String;
  final titleController = TextEditingController();
  final tagsController = TextEditingController();

  List<String> tags = [];

  // parse fields to actual widgets
  final widgets = <Widget>[].obs;

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
      titleController.text = item!.title;
      favorite.value = item!.favorite;
    }

    widgets.value = item!.widgets;
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

  Future<void> _loadTemplate() async {
    item = HiveLisoItem(
      category: category,
      icon: Uint8List.fromList(''.codeUnits), // TODO: update icon
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
      icon: Uint8List.fromList(''.codeUnits), // TODO: update icon
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

    item!.icon = Uint8List.fromList(''.codeUnits); // TODO: update icon
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
}
