import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/form_field.util.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';

import '../../core/hive/hive.manager.dart';
import '../../core/hive/models/metadata/metadata.hive.dart';
import '../../core/parsers/template.parser.dart';
import '../../core/utils/utils.dart';
import '../drawer/drawer_widget.controller.dart';
import '../menu/menu.item.dart';

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
  final menuKey = GlobalKey<FormState>();
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
  final protected = false.obs;

  // GETTERS
  // MENU ITEMS
  List<ContextMenuItem> get menuItems {
    return [
      ContextMenuItem(
        title: 'copy'.tr + ' ${item!.significant.keys.first}',
        leading: const Icon(LineIcons.copy),
        onSelected: () => Utils.copyToClipboard(item!.significant.values.first),
      ),
      if (item!.categoryObject == LisoItemCategory.cryptoWallet) ...[
        // TODO: export wallet and generate qr code
        ContextMenuItem(
          title: 'export_wallet'.tr,
          leading: const Icon(LineIcons.fileExport),
          onSelected: () {},
        ),
        ContextMenuItem(
          title: 'QR Code',
          leading: const Icon(LineIcons.qrcode),
          onSelected: () {},
        ),
      ]
    ];
  }

  List<ContextMenuItem> get menuItemsChangeIcon {
    return [
      ContextMenuItem(
        title: 'change'.tr,
        leading: const Icon(LineIcons.image),
        onSelected: _pickIcon,
      ),
      if (icon.value.isNotEmpty) ...[
        ContextMenuItem(
          title: 'remove'.tr,
          leading: const Icon(LineIcons.trash),
          onSelected: () => icon.value = Uint8List(0),
        ),
      ]
    ];
  }

  // INIT
  @override
  void onInit() async {
    if (mode == 'add') {
      await _loadTemplate();
    } else if (mode == 'update') {
      _populateItem();
    }

    widgets.value = item!.widgets;
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS
  void _populateItem() {
    final hiveKey = Get.parameters['hiveKey'].toString();
    item = HiveManager.items!.get(int.parse(hiveKey));
    icon.value = item!.icon;
    titleController.text = item!.title;
    favorite.value = item!.favorite;
    protected.value = item!.protected;
    tags = item!.tags;
  }

  Future<void> _loadTemplate() async {
    final drawerController = Get.find<DrawerMenuController>();

    favorite.value = drawerController.filterFavorites.value;
    protected.value = drawerController.filterProtected.value;

    final _fields = TemplateParser.parse(category);

    item = HiveLisoItem(
      category: category,
      icon: Uint8List(0),
      title: '',
      fields: _fields,
      tags: [],
      metadata: await HiveMetadata.get(),
      favorite: favorite.value,
      protected: protected.value,
    );
  }

  void add() async {
    if (!formKey.currentState!.validate()) return;

    final _fields = FormFieldUtils.obtainFields(item!, widgets: widgets);

    final newItem = HiveLisoItem(
      category: category,
      icon: icon(),
      title: titleController.text,
      tags: tags,
      fields: _fields,
      metadata: await HiveMetadata.get(),
      favorite: favorite(),
      protected: protected(),
    );

    await HiveManager.items!.add(newItem);
    Get.back();
  }

  void edit() async {
    if (!formKey.currentState!.validate()) return;
    if (item == null) return;

    item!.icon = icon();
    item!.title = titleController.text;
    item!.fields = FormFieldUtils.obtainFields(item!, widgets: widgets);
    item!.tags = tags;
    item!.favorite = favorite();
    item!.protected = protected();
    item!.metadata = await item!.metadata.getUpdated();
    await item!.save();

    Get.back();
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

  void _pickIcon() async {
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(type: FileType.image);
    } catch (e) {
      return console.error('FilePicker error: $e');
    }

    if (result == null || result.files.isEmpty) {
      return console.warning("canceled FilePicker");
    }

    final image = result.files.single;

    final file = File(image.path!);
    if (!await file.exists()) return console.warning("doesn't exist");

    if (await file.length() > kMaxIconSize) {
      return UIUtils.showSimpleDialog(
        'Image Too Large',
        'Please choose an image with size not larger than ${filesize(kMaxIconSize)}',
      );
    }

    icon.value = await file.readAsBytes();
  }
}
