import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/utils/console.dart';

import '../../core/custom_widgets/custom_dropdown.field.dart';
import '../../core/hive/hive.manager.dart';
import '../../core/hive/models/field.hive.dart';
import '../../core/hive/models/metadata/metadata.hive.dart';
import '../../core/notifications/notifications.manager.dart';
import '../../core/parsers/template.parser.dart';
import '../general/selector.sheet.dart';
import '../main/main_screen.controller.dart';

class ItemScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ItemScreenController());
  }
}

class ItemScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  // VARIABLES
  HiveLisoItem? object;

  final formKey = GlobalKey<FormState>();
  final mode = Get.parameters['mode'] as String;
  final template = Get.parameters['template'] as String;
  final titleController = TextEditingController();

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
      final index = int.parse(Get.parameters['index'].toString());
      object = HiveManager.items!.getAt(index);
      titleController.text = object!.title;
    }

    widgets.addAll(object!.widgets);
    change(null, status: RxStatus.success());

    super.onInit();
  }

  // FUNCTIONS

  Future<void> _loadTemplate() async {
    object = HiveLisoItem(
      icon: '',
      title: '',
      fields: TemplateParser.parse(template),
      tags: [template],
      metadata: await HiveMetadata.get(),
    );
  }

  List<HiveLisoField> _obtainFields() {
    final List<HiveLisoField> _newFields = [];

    for (var i = 0; i < object!.fields.length; i++) {
      final _field = object!.fields[i];
      var _widget = widgets[i]; // TODO: could use object!.widgets()

      // TEXT FIELDS
      if (_field.type == LisoFieldType.textField.name ||
          _field.type == LisoFieldType.textArea.name ||
          _field.type == LisoFieldType.password.name ||
          _field.type == LisoFieldType.url.name) {
        final textField = _widget as TextFormField;
        _field.data['value'] = textField.controller!.text;
      }

      // DROPDOWNS
      if (_field.type == LisoFieldType.gender.name ||
          _field.type == LisoFieldType.country.name) {
        final dropDown = _widget as CustomDropDownFormField;
        _field.data['value'] = dropDown.value;
      }

      _newFields.add(_field);
    }

    return _newFields;
  }

  void add() async {
    if (!formKey.currentState!.validate()) return;

    final newItem = HiveLisoItem(
      icon: '', // TODO: update icon
      title: titleController.text,
      tags: [template], // TODO: add custom tags
      fields: _obtainFields(),
      metadata: await HiveMetadata.get(),
    );

    await HiveManager.items!.add(newItem);

    NotificationsManager.notify(
      title: 'Item Added',
      body: "A new item is added", // TODO: some body
    );

    MainScreenController.to.load();
    Get.back();
  }

  void edit() async {
    if (!formKey.currentState!.validate()) return;
    if (object == null) return;

    object!.title = titleController.text;
    object!.fields = _obtainFields();
    // object!.tags = []; // TODO: update tags
    object!.metadata = await object!.metadata.getUpdated();
    await object?.save();

    NotificationsManager.notify(
      title: 'Item has been updated',
      body: object!.tags.first, // TODO: some body
    );

    MainScreenController.to.load();
    Get.back();
  }

  void delete() {
    void _proceed() async {
      await object?.delete();

      NotificationsManager.notify(
        title: 'Item has been deleted',
        body: object!.tags.first, // TODO: some body
      );

      MainScreenController.to.load();
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
