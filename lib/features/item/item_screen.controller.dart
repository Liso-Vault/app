import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/form_field.util.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:uuid/uuid.dart';

import '../../core/hive/hive_groups.service.dart';
import '../../core/hive/hive_items.service.dart';
import '../../core/hive/models/metadata/metadata.hive.dart';
import '../../core/parsers/template.parser.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../drawer/drawer_widget.controller.dart';
import '../menu/menu.button.dart';
import '../menu/menu.item.dart';
import '../shared_vaults/shared_vault.controller.dart';

class ItemScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ItemScreenController(), fenix: true);
  }
}

class ItemScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  static ItemScreenController get to => Get.find();

  // VARIABLES
  late HiveLisoItem item, originalItem;

  final formKey = GlobalKey<FormState>();
  final menuKey = GlobalKey<FormState>();
  final mode = Get.parameters['mode'] as String;
  final category = Get.parameters['category'] as String;
  final titleController = TextEditingController();
  final tagsController = TextEditingController();

  Set<String> tags = {};
  final iconUrl = ''.obs;
  final widgets = <Widget>[].obs;

  // PROPERTIES
  final favorite = false.obs;
  final protected = false.obs;
  final groupId = Persistence.to.groupId.val.obs;
  // TODO: convert to Sets
  final attachments = <String>[].obs;
  final sharedVaultIds = <String>[].obs;

  // GETTERS
  // MENU ITEMS
  List<ContextMenuItem> get menuItems {
    return [
      ContextMenuItem(
        title: '${'copy'.tr} ${item.significant.keys.first}',
        leading: const Icon(Iconsax.copy),
        onSelected: () => Utils.copyToClipboard(item.significant.values.first),
      ),
      // if (item.categoryObject == LisoItemCategory.cryptoWallet) ...[
      //   // TODO: export wallet and generate qr code
      //   ContextMenuItem(
      //     title: 'export_wallet'.tr,
      //     leading: const Icon(Iconsax.export_1),
      //     onSelected: () {},
      //   ),
      //   ContextMenuItem(
      //     title: 'QR Code',
      //     leading: const Icon(Iconsax.barcode),
      //     onSelected: () {},
      //   ),
      // ]
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

  List<Widget> get sharedVaultChips {
    List<Widget> chips = sharedVaultIds.map<Widget>((vaultId) {
      final results = SharedVaultsController.to.data
          .where((vault) => vault.data().docId == vaultId);

      String name = vaultId;

      if (results.isNotEmpty) {
        name = results.first.data().name;
      }

      return ActionChip(
        label: Text(name),
        onPressed: () => sharedVaultIds.remove(vaultId),
      );
    }).toList();

    final menuItems = SharedVaultsController.to.data
        .where((e) => !sharedVaultIds.contains(e.data().docId))
        .map((e) {
      final vault = e.data();
      return ContextMenuItem(
        title: vault.name,
        value: e.id,
        leading: const Icon(Iconsax.share), // TODO: RemoteImage
        onSelected: () {
          if (sharedVaultIds.contains(vault.docId)) return;
          sharedVaultIds.add(vault.docId);
        },
      );
    }).toList();

    if (menuItems.isNotEmpty) {
      chips.add(ContextMenuButton(
        menuItems,
        padding: EdgeInsets.zero,
        child: const Chip(
          label: Text('Assign'),
          avatar: Icon(Iconsax.add),
        ),
      ));
    }

    return chips;
  }

  // INIT
  @override
  void onInit() async {
    for (final e in HiveGroupsService.to.data) {
      console.warning('group: ${e.id}');
    }

    if (mode == 'add') {
      await _loadTemplate();
    } else if (mode == 'update') {
      _populateItem();
    }

    originalItem = HiveLisoItem.fromJson(item.toJson());
    widgets.value = item.widgets;
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS
  void _populateItem() {
    final hiveKey = Get.parameters['hiveKey'].toString();
    item = HiveItemsService.to.box.get(int.parse(hiveKey))!;
    iconUrl.value = item.iconUrl;
    titleController.text = item.title;
    favorite.value = item.favorite;
    protected.value = item.protected;
    groupId.value = item.groupId;
    tags = item.tags.toSet();
    attachments.value = List.from(item.attachments);
    sharedVaultIds.value = List.from(item.sharedVaultIds);
  }

  Future<void> _loadTemplate() async {
    final drawerController = Get.find<DrawerMenuController>();
    groupId.value = drawerController.filterGroupId.value;
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
      attachments: [],
      sharedVaultIds: [],
      favorite: favorite.value,
      protected: protected.value,
      metadata: await HiveMetadata.get(),
      groupId: groupId.value,
    );
  }

  void add() async {
    if (!formKey.currentState!.validate()) return;
    // items limit
    if (HiveItemsService.to.itemLimitReached) {
      return Utils.adaptiveRouteOpen(
        name: Routes.upgrade,
        parameters: {
          'title': 'Title',
          'body': 'Maximum items limit reached',
        }, // TODO: add message
      );
    }

    // protected items limit
    if (protected.value && HiveItemsService.to.protectedItemLimitReached) {
      return Utils.adaptiveRouteOpen(
        name: Routes.upgrade,
        parameters: {
          'title': 'Title',
          'body': 'Maximum protected items limit reached',
        }, // TODO: add message
      );
    }

    final newItem = HiveLisoItem(
      identifier: const Uuid().v4(),
      category: category,
      iconUrl: iconUrl.value,
      title: titleController.text,
      tags: tags.toList(),
      attachments: attachments,
      sharedVaultIds: sharedVaultIds,
      fields: FormFieldUtils.obtainFields(item, widgets: widgets),
      favorite: favorite.value,
      protected: protected.value,
      metadata: await HiveMetadata.get(),
      groupId: groupId.value,
    );

    await HiveItemsService.to.box.add(newItem);
    MainScreenController.to.onItemsUpdated();
    Get.back();
  }

  void edit() async {
    if (!formKey.currentState!.validate()) return;

    // protected items limit
    if (protected.value && HiveItemsService.to.protectedItemLimitReached) {
      return Utils.adaptiveRouteOpen(
        name: Routes.upgrade,
        parameters: {
          'title': 'Title',
          'body': 'Maximum protected items limit reached',
        }, // TODO: add message
      );
    }

    item.iconUrl = iconUrl.value;
    item.title = titleController.text;
    item.fields = FormFieldUtils.obtainFields(item, widgets: widgets);
    item.tags = tags.toList();
    item.attachments = attachments;
    item.sharedVaultIds = sharedVaultIds;
    item.favorite = favorite.value;
    item.protected = protected.value;
    item.groupId = groupId.value;
    item.metadata = await item.metadata.getUpdated();
    await item.save();

    MainScreenController.to.onItemsUpdated();
    Get.back();
  }

  List<String> querySuggestions(String query) {
    if (query.isEmpty) return [];

    final usedTags = HiveItemsService.to.data
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
        labelText: 'Icon URL',
        hintText: 'https://images.com/icon.png',
      ),
    );

    Get.dialog(AlertDialog(
      title: const Text('Custom Icon'),
      content: Form(
        key: formKey,
        child: Utils.isDrawerExpandable
            ? content
            : SizedBox(width: 450, child: content),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
        TextButton(onPressed: _save, child: Text('save'.tr)),
      ],
    ));
  }

  Future<bool> canPop() async {
    // TODO: improve equality check
    final updatedItem = HiveLisoItem(
      identifier: item.identifier,
      metadata: item.metadata,
      trashed: item.trashed,
      deleted: item.deleted,
      category: category,
      title: titleController.text,
      fields: FormFieldUtils.obtainFields(item, widgets: widgets),
      attachments: attachments,
      sharedVaultIds: sharedVaultIds,
      tags: tags.toList(),
      groupId: groupId.value,
      favorite: favorite.value,
      iconUrl: iconUrl.value,
      protected: protected.value,
    );

    // convert to json string for absolute equality check
    bool hasChanges = updatedItem.toJsonString() != originalItem.toJsonString();

    if (hasChanges) {
      const dialogContent = Text('You have unsaved changes');

      await Get.dialog(AlertDialog(
        title: const Text('Unsaved Changes'),
        content: Utils.isDrawerExpandable
            ? dialogContent
            : const SizedBox(width: 450, child: dialogContent),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              hasChanges = false;
              Get.back();
            },
            child: const Text('Discard'),
          ),
        ],
      ));
    }

    return !hasChanges;
  }

  void attach() async {
    final attachments_ = await Utils.adaptiveRouteOpen(
      name: Routes.attachments,
      parameters: {'attachments': attachments.join(',')},
    );

    if (attachments_ == null) return;
    attachments.value = attachments_;
  }
}
