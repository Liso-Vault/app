import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/form_field.util.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:uuid/uuid.dart';

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
  final iconUrl = ''.obs;

  // PROPERTIES
  final favorite = false.obs;
  final protected = false.obs;
  final groupIndex = PersistenceService.to.groupIndex.val.obs;

  // GETTERS
  // MENU ITEMS
  List<ContextMenuItem> get menuItems {
    return [
      ContextMenuItem(
        title: '${'copy'.tr} ${item!.significant.keys.first}',
        leading: const Icon(Iconsax.copy),
        onSelected: () => Utils.copyToClipboard(item!.significant.values.first),
      ),
      if (item!.categoryObject == LisoItemCategory.cryptoWallet) ...[
        // TODO: export wallet and generate qr code
        ContextMenuItem(
          title: 'export_wallet'.tr,
          leading: const Icon(Iconsax.export_1),
          onSelected: () {},
        ),
        ContextMenuItem(
          title: 'QR Code',
          leading: const Icon(Iconsax.barcode),
          onSelected: () {},
        ),
      ]
    ];
  }

  List<ContextMenuItem> get menuItemsChangeIcon {
    return [
      ContextMenuItem(
        title: 'change'.tr,
        leading: const Icon(Iconsax.gallery),
        onSelected: _pickIcon,
      ),
      if (iconUrl.value.isNotEmpty) ...[
        ContextMenuItem(
          title: 'remove'.tr,
          leading: const Icon(Iconsax.trash),
          onSelected: () => iconUrl.value = '',
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
    iconUrl.value = item!.iconUrl;
    titleController.text = item!.title;
    favorite.value = item!.favorite;
    protected.value = item!.protected;
    groupIndex.value = item!.group;
    tags = item!.tags;
  }

  Future<void> _loadTemplate() async {
    final drawerController = Get.find<DrawerMenuController>();
    groupIndex.value = drawerController.filterGroupIndex.value;
    favorite.value = drawerController.filterFavorites.value;

    // protected templates by default
    final protectedCategories = [
      LisoItemCategory.cryptoWallet,
      LisoItemCategory.cashCard,
      LisoItemCategory.bankAccount,
      LisoItemCategory.apiCredential,
      LisoItemCategory.email,
      LisoItemCategory.login,
      LisoItemCategory.passport,
      LisoItemCategory.encryption,
      LisoItemCategory.wirelessRouter,
    ];

    protected.value = drawerController.filterProtected.value ||
        protectedCategories.contains(LisoItemCategory.values.byName(category));

    final fields = TemplateParser.parse(category);

    item = HiveLisoItem(
      identifier: const Uuid().v4(),
      category: category,
      title: '',
      fields: fields,
      tags: [],
      favorite: favorite.value,
      protected: protected.value,
      metadata: await HiveMetadata.get(),
      group: groupIndex.value,
    );
  }

  void add() async {
    if (!formKey.currentState!.validate()) return;
    final fields = FormFieldUtils.obtainFields(item!, widgets: widgets);

    final newItem = HiveLisoItem(
      identifier: const Uuid().v4(),
      category: category,
      iconUrl: iconUrl.value,
      title: titleController.text,
      tags: tags,
      fields: fields,
      favorite: favorite.value,
      protected: protected.value,
      metadata: await HiveMetadata.get(),
      group: groupIndex.value,
    );

    await HiveManager.items!.add(newItem);
    Get.back();
  }

  void edit() async {
    if (!formKey.currentState!.validate()) return;
    if (item == null) return;

    item!.iconUrl = iconUrl.value;
    item!.title = titleController.text;
    item!.fields = FormFieldUtils.obtainFields(item!, widgets: widgets);
    item!.tags = tags;
    item!.favorite = favorite.value;
    item!.protected = protected.value;
    item!.metadata = await item!.metadata.getUpdated();
    item!.group = groupIndex.value;
    await item!.save();

    Get.back();
  }

  List<String> querySuggestions(String query) {
    if (query.isEmpty) return [];

    final usedTags = HiveManager.items!.values
        .map((e) => e.tags.where((x) => x.isNotEmpty).toList())
        .toSet();

    // include query as a suggested tag
    final Set<String> tags = {query};

    if (usedTags.isNotEmpty) {
      tags.addAll(usedTags.reduce((a, b) => a + b).toSet());
    }

    final filteredTags = tags.where(
      (e) => e.toLowerCase().contains(query.toLowerCase()),
    );

    return filteredTags.toList();
  }

  void querySubmitted() {
    // TODO: add tag when submitted
    // tags.add(tagsController.text);
  }

  void _pickIcon() async {
    final formKey = GlobalKey<FormState>();
    final iconController = TextEditingController();

    void _save() async {
      if (!formKey.currentState!.validate()) return;
      iconUrl.value = iconController.text;
      Get.back();
    }

    final content = TextFormField(
      controller: iconController,
      autofocus: true,
      keyboardType: TextInputType.url,
      validator: (data) =>
          data!.isEmpty || GetUtils.isURL(data) ? null : 'Invalid URL',
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: const InputDecoration(
        labelText: 'Name',
        hintText: 'https://images.com/icon.png',
      ),
    );

    Get.dialog(AlertDialog(
      title: const Text('Icon URL'),
      content: Form(
        key: formKey,
        child: Utils.isDrawerExpandable
            ? content
            : SizedBox(width: 600, child: content),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: _save,
          child: Text('save'.tr),
        ),
      ],
    ));
  }
}
