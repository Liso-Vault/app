import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/form_fields/richtext.field.dart';
import 'package:liso/core/hive/models/category.hive.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/categories/categories.controller.dart';
import 'package:liso/features/general/section.widget.dart';
import 'package:liso/features/joined_vaults/explorer/vault_explorer_screen.controller.dart';
import 'package:liso/features/tags/tags_input.controller.dart';
import 'package:uuid/uuid.dart';

import '../../core/hive/models/metadata/metadata.hive.dart';
import '../../core/persistence/persistence.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../drawer/drawer_widget.controller.dart';
import '../menu/menu.button.dart';
import '../menu/menu.item.dart';
import '../s3/s3.service.dart';
import '../shared_vaults/shared_vault.controller.dart';
import 'items.controller.dart';
import 'items.service.dart';

class ItemScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  static ItemScreenController get to => Get.find();

  // VARIABLES
  HiveLisoItem? item;
  late HiveLisoItem originalItem;

  final formKey = GlobalKey<FormState>();
  final menuKey = GlobalKey<FormState>();
  final mode = Get.parameters['mode'];
  final joinedVaultItem = Get.parameters['joinedVaultItem'] == 'true';
  final titleController = TextEditingController();
  final tagsController = Get.put(TagsInputController());

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
  ].map((e) => e.name);

  final iconUrl = ''.obs;
  final widgets = <Widget>[].obs;

  // PROPERTIES
  final favorite = false.obs;
  final protected = false.obs;
  final reserved = false.obs;
  final groupId = DrawerMenuController.to.filterGroupId.value.obs;
  final category = Get.parameters['category']!.obs;
  final attachments = <String>[].obs;
  final sharedVaultIds = <String>[].obs;
  final editMode = (Get.parameters['mode'] != 'view').obs;

  // GETTERS
  List<HiveLisoField> get parseFields => widgets.map((e) {
        final formWidget = (e as dynamic).children.first.child;
        final field = formWidget.field as HiveLisoField;

        if (formWidget?.value is Map<String, dynamic>) {
          field.data.extra = formWidget.value;
        } else {
          field.data.value = formWidget?.value ?? '';
        }

        return field;
      }).toList();

  bool get canEdit => !joinedVaultItem && editMode.value;

  HiveLisoCategory get categoryObject {
    final categories_ =
        CategoriesController.to.combined.where((e) => e.id == category.value);
    if (categories_.isNotEmpty) return categories_.first;
    return HiveLisoCategory(
      id: category.value,
      name: category.value,
      metadata: null,
    );
  }

  // MENU ITEMS
  List<ContextMenuItem> get menuItems {
    return [
      ContextMenuItem(
        title: '${'copy'.tr} ${item?.significant['name']}',
        leading: const Icon(Iconsax.copy),
        onSelected: () => Utils.copyToClipboard(item!.significant.values.first),
      ),
      // if (item.categoryObject == LisoItemCategory.cryptoWallet) ...[
      //   ContextMenuItem(
      //     title: 'QR Code',
      //     leading: const Icon(Iconsax.barcode),
      //     onSelected: () {},
      //   ),
      // ]
      if (kDebugMode) ...[
        ContextMenuItem(
          title: 'Force Close',
          leading: const Icon(Iconsax.slash),
          onSelected: Get.back,
        ),
      ]
    ];
  }

  List<ContextMenuItem> get menuFieldItems => [
        ContextMenuItem(
          title: 'Text Field',
          leading: const Icon(Iconsax.text),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.textField.name,
              data: HiveLisoFieldData(label: 'Text Field'),
            );

            widgets.add(_buildFieldWidget(field.widget));
          },
        ),
        ContextMenuItem(
          title: 'Textarea Field',
          leading: const Icon(Iconsax.text),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.textArea.name,
              data: HiveLisoFieldData(label: 'Textarea Field'),
            );

            widgets.add(_buildFieldWidget(field.widget));
          },
        ),
        ContextMenuItem(
          title: 'Password Field',
          leading: const Icon(Iconsax.password_check),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.password.name,
              data: HiveLisoFieldData(label: 'Password Field'),
            );

            widgets.add(_buildFieldWidget(field.widget));
          },
        ),
        ContextMenuItem(
          title: 'Phone Field',
          leading: const Icon(LineIcons.phone),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.phone.name,
              data: HiveLisoFieldData(label: 'Phone Field'),
            );

            widgets.add(_buildFieldWidget(field.widget));
          },
        ),
        ContextMenuItem(
          title: 'PIN Field',
          leading: const Icon(Iconsax.code),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.pin.name,
              data: HiveLisoFieldData(label: 'PIN Field'),
            );

            widgets.add(_buildFieldWidget(field.widget));
          },
        ),
        ContextMenuItem(
          title: 'URL Field',
          leading: const Icon(Iconsax.link),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.url.name,
              data: HiveLisoFieldData(label: 'URL Field'),
            );

            widgets.add(_buildFieldWidget(field.widget));
          },
        ),
        ContextMenuItem(
          title: 'Date Field',
          leading: const Icon(Iconsax.calendar),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.date.name,
              data: HiveLisoFieldData(label: 'Date Field'),
            );

            widgets.add(_buildFieldWidget(field.widget));
          },
        ),
        ContextMenuItem(
          title: 'Email Field',
          leading: const Icon(Iconsax.message),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.email.name,
              data: HiveLisoFieldData(label: 'Email Field'),
            );

            widgets.add(_buildFieldWidget(field.widget));
          },
        ),
        ContextMenuItem(
          title: 'Number Field',
          leading: const Icon(Icons.numbers),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.number.name,
              data: HiveLisoFieldData(label: 'Number Field'),
            );

            widgets.add(_buildFieldWidget(field.widget));
          },
        ),
        ContextMenuItem(
          title: 'Passport Field',
          leading: const Icon(Iconsax.card),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.passport.name,
              data: HiveLisoFieldData(label: 'Passport Field'),
            );

            widgets.add(_buildFieldWidget(field.widget));
          },
        ),
        ContextMenuItem(
          title: 'Address Field',
          leading: const Icon(Iconsax.location),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.address.name,
              data: HiveLisoFieldData(label: 'Address Field'),
            );

            widgets.add(_buildFieldWidget(field.widget));
          },
        ),
        ContextMenuItem(
          title: 'Section',
          leading: const Icon(Icons.text_fields),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.section.name,
              data: HiveLisoFieldData(
                label: 'Section',
              ),
            );

            widgets.add(_buildFieldWidget(field.widget));
          },
        ),
      ];

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
          .where((vault) => vault.docId == vaultId);

      String name = vaultId;
      if (results.isNotEmpty) name = results.first.name;

      return Chip(
        label: Text(name),
        onDeleted: joinedVaultItem || !editMode.value
            ? null
            : () => sharedVaultIds.remove(vaultId),
      );
    }).toList();

    final menuItems = SharedVaultsController.to.data
        .where((e) => !sharedVaultIds.contains(e.docId))
        .map((vault) {
      return ContextMenuItem(
        title: vault.name,
        value: vault.docId,
        leading: const Icon(Iconsax.share), // TODO: RemoteImage
        onSelected: () {
          if (sharedVaultIds.contains(vault.docId)) return;
          sharedVaultIds.add(vault.docId);
        },
      );
    }).toList();

    if (menuItems.isNotEmpty && !joinedVaultItem && editMode.value) {
      chips.add(ContextMenuButton(
        menuItems,
        padding: EdgeInsets.zero,
        child: ActionChip(
          label: const Icon(Iconsax.add_circle5, size: 20),
          onPressed: () {},
        ),
      ));
    }

    return chips;
  }

  List<Widget> get attachmentChips {
    List<Widget> chips = attachments.map<Widget>((attachment) {
      final content = S3Service.to.contentsCache.firstWhere(
        (e) => e.object!.eTag == attachment,
      );

      return Chip(
        label: Text(content.name),
        onDeleted: joinedVaultItem || !editMode.value
            ? null
            : () => attachments.remove(attachment),
      );
    }).toList();

    if (!joinedVaultItem && editMode.value) {
      chips.add(ActionChip(
        label: const Icon(Iconsax.add_circle5, size: 20),
        onPressed: attach,
      ));
    }

    return chips;
  }

  // INIT
  @override
  void onInit() async {
    if (mode == 'add') {
      await _loadTemplate();
    } else if (mode == 'view') {
      _loadItem();
    } else if (mode == 'generated') {
      await _populateGeneratedItem();
    }

    originalItem = HiveLisoItem.fromJson(item!.toJson());
    _populateItem();
    change(null, status: RxStatus.success());

    // re-populate widgets
    editMode.listen((value) {
      _populateItem();
    });

    super.onInit();
  }

  // FUNCTIONS
  Future<void> _populateGeneratedItem() async {
    final value = Get.parameters['value'];
    String identifier = '';

    if (category.value == LisoItemCategory.password.name) {
      identifier = 'password';
    } else if (category.value == LisoItemCategory.cryptoWallet.name) {
      identifier = 'seed';
    }

    var fields = categoryObject.fields;
    fields = fields.map((e) {
      if (e.identifier != identifier) return e;
      e.data.value = value;
      e.readOnly = true;
      return e;
    }).toList();

    item = HiveLisoItem(
      identifier: const Uuid().v4(),
      category: category.value,
      title: 'Generated ${GetUtils.capitalizeFirst(identifier)}',
      fields: fields,
      tags: [],
      attachments: [],
      sharedVaultIds: [],
      favorite: false,
      protected: true,
      metadata: await HiveMetadata.get(),
      groupId: groupId.value,
    );
  }

  void _loadItem() {
    if (!joinedVaultItem) {
      final hiveKey = Get.parameters['hiveKey'].toString();
      item = ItemsService.to.box!.get(int.parse(hiveKey))!;
    } else {
      final identifier = Get.parameters['identifier'].toString();
      item = VaultExplorerScreenController.to.data.firstWhere(
        (e) => e.identifier == identifier,
      );
    }
  }

  void _populateItem() {
    iconUrl.value = item!.iconUrl;
    titleController.text = item!.title;
    favorite.value = item!.favorite;
    protected.value = item!.protected;
    reserved.value = item!.reserved;
    groupId.value = item!.groupId;
    attachments.value = List.from(item!.attachments);
    sharedVaultIds.value = List.from(item!.sharedVaultIds);
    tagsController.data.value = item!.tags.toSet().toList();
    _buildFieldWidgets();
  }

  Widget _buildFieldWidget(Widget widget) {
    final dragHandle = Row(
      children: [
        if (!joinedVaultItem) ...[
          if (Utils.isDrawerExpandable || GetPlatform.isMobile) ...[
            const SizedBox(width: 10),
            const Icon(Icons.drag_handle_rounded),
          ] else ...[
            const SizedBox(width: 40),
          ],
        ],
      ],
    );

    return Row(
      key: Key(const Uuid().v4()),
      children: [
        Expanded(child: widget),
        Obx(() => Visibility(visible: editMode.value, child: dragHandle))
      ],
    );
  }

  void _buildFieldWidgets() {
    // filter empty fields
    List<Widget> widgets_ = item!.widgets;

    if (!editMode.value) {
      widgets_.removeWhere((e) {
        final field = (e as dynamic).field as HiveLisoField;
        return field.data.value!.isEmpty && field.data.extra == null;
      });
    }

    widgets.value = widgets_.asMap().entries.map(
      (e) {
        Widget widget = e.value;

        if (!editMode.value) {
          final field = (e.value as dynamic).field as HiveLisoField;

          if (field.type == LisoFieldType.section.name) {
            widget = Section(
                text:
                    (field.data.label ?? field.data.value ?? '').toUpperCase());
          } else if (field.type == LisoFieldType.richText.name) {
            widget = RichTextFormField(field, readOnly: true);
          } else if (field.type == LisoFieldType.address.name) {
            String street1 = field.data.extra!['street1'];
            String street2 = field.data.extra!['street2'];
            String city = field.data.extra!['city'];
            String state = field.data.extra!['state'];
            String zip = field.data.extra!['zip'];
            String country = field.data.extra!['country'] ?? '';

            widget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION
                Section(text: field.data.label ?? field.data.value ?? ''),
                // STREET 1
                if (street1.isNotEmpty) ...[
                  InkWell(
                    onTap: () => Utils.copyToClipboard(street1),
                    child: TextFormField(
                      initialValue: street1,
                      enabled: false,
                      decoration: const InputDecoration(labelText: 'Street 1'),
                    ),
                  ),
                ],
                if (street2.isNotEmpty) ...[
                  InkWell(
                    onTap: () => Utils.copyToClipboard(street2),
                    child: TextFormField(
                      initialValue: street2,
                      enabled: false,
                      decoration: const InputDecoration(labelText: 'Street 2'),
                    ),
                  ),
                ],
                if (city.isNotEmpty) ...[
                  InkWell(
                    onTap: () => Utils.copyToClipboard(city),
                    child: TextFormField(
                      initialValue: city,
                      enabled: false,
                      decoration: const InputDecoration(labelText: 'City'),
                    ),
                  ),
                ],
                if (state.isNotEmpty) ...[
                  InkWell(
                    onTap: () => Utils.copyToClipboard(state),
                    child: TextFormField(
                      initialValue: state,
                      enabled: false,
                      decoration:
                          const InputDecoration(labelText: 'State / Province'),
                    ),
                  ),
                ],
                if (zip.isNotEmpty) ...[
                  InkWell(
                    onTap: () => Utils.copyToClipboard(zip),
                    child: TextFormField(
                      initialValue: zip,
                      enabled: false,
                      decoration: const InputDecoration(labelText: 'Zip Code'),
                    ),
                  ),
                ],
                if (country.isNotEmpty) ...[
                  InkWell(
                    onTap: () => Utils.copyToClipboard(country),
                    child: TextFormField(
                      initialValue: country,
                      enabled: false,
                      decoration: const InputDecoration(labelText: 'Country'),
                    ),
                  ),
                ],
              ],
            );
          } else {
            bool obscured = field.type == LisoFieldType.password.name ||
                field.type == LisoFieldType.mnemonicSeed.name ||
                field.type == LisoFieldType.pin.name;

            // add a quick copy value feature when tapped
            widget = InkWell(
              onTap: () => Utils.copyToClipboard(field.data.value),
              child: TextFormField(
                initialValue: field.data.value,
                enabled: false,
                obscureText: obscured,
                minLines: 1,
                maxLines: obscured ? 1 : 10,
                decoration: InputDecoration(
                  labelText: field.data.label,
                  hintText: field.data.hint,
                ),
              ),
            );
          }
        }

        return _buildFieldWidget(widget);
      },
    ).toList();
  }

  Future<void> _loadTemplate() async {
    final drawerController = Get.find<DrawerMenuController>();
    final protected_ = drawerController.filterProtected.value ||
        protectedCategories.contains(category.value);

    item = HiveLisoItem(
      identifier: const Uuid().v4(),
      category: category.value,
      title: '',
      fields: categoryObject.fields,
      tags: [],
      attachments: [],
      sharedVaultIds: [],
      favorite: drawerController.filterFavorites.value,
      protected: protected_,
      metadata: await HiveMetadata.get(),
      groupId: drawerController.filterGroupId.value,
    );
  }

  void add() async {
    if (!formKey.currentState!.validate()) return;
    // items limit
    if (ItemsService.to.itemLimitReached) {
      return Utils.adaptiveRouteOpen(
        name: Routes.upgrade,
        parameters: {
          'title': 'Title',
          'body': 'Maximum items limit reached',
        }, // TODO: add message
      );
    }

    // protected items limit
    if (protected.value && ItemsService.to.protectedItemLimitReached) {
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
      category: category.value,
      iconUrl: iconUrl.value,
      title: titleController.text,
      tags: tagsController.data,
      attachments: attachments,
      sharedVaultIds: sharedVaultIds,
      fields: parseFields,
      favorite: favorite.value,
      protected: protected.value,
      metadata: await HiveMetadata.get(),
      groupId: groupId.value,
    );

    await ItemsService.to.box!.add(newItem);
    Persistence.to.changes.val++;
    ItemsController.to.load();
    Get.back();
  }

  void edit() async {
    if (!formKey.currentState!.validate()) return;

    // protected items limit
    if (protected.value && ItemsService.to.protectedItemLimitReached) {
      return Utils.adaptiveRouteOpen(
        name: Routes.upgrade,
        parameters: {
          'title': 'Title',
          'body': 'Maximum protected items limit reached',
        }, // TODO: add message
      );
    }

    item!.iconUrl = iconUrl.value;
    item!.title = titleController.text;
    item!.fields = parseFields;
    item!.tags = tagsController.data;
    item!.attachments = attachments;
    item!.sharedVaultIds = sharedVaultIds;
    item!.favorite = favorite.value;
    item!.protected = protected.value;
    item!.groupId = groupId.value;
    item!.category = category.value;
    item!.metadata = await item!.metadata.getUpdated();
    await item!.save();

    Persistence.to.changes.val++;
    ItemsController.to.load();
    Get.back();
  }

  List<String> querySuggestions(String query) {
    if (query.isEmpty) return [];

    final usedTags = ItemsService.to.data
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
    if (!editMode.value) return true;

    // TODO: improve equality check
    final updatedItem = HiveLisoItem(
      identifier: item!.identifier,
      metadata: item!.metadata,
      trashed: item!.trashed,
      deleted: item!.deleted,
      category: category.value,
      title: titleController.text,
      fields: parseFields,
      attachments: attachments,
      sharedVaultIds: sharedVaultIds,
      tags: tagsController.data,
      groupId: groupId.value,
      favorite: favorite.value,
      iconUrl: iconUrl.value,
      protected: protected.value,
      reserved: item!.reserved,
      hidden: item!.hidden,
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

  Future<void> showFieldProperties(dynamic formWidget) async {
    final field = formWidget.children.first.child.field;
    final formKey = GlobalKey<FormState>();
    final labelController = TextEditingController(text: field.data.label);
    final hintController = TextEditingController(text: field.data.hint);

    void _update() async {
      if (!formKey.currentState!.validate()) return;
      field.data.label = labelController.text;
      field.data.hint = hintController.text;
      Get.back();
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: labelController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          maxLength: 20,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (data) => data!.isEmpty ? 'Invalid Label' : null,
          decoration: const InputDecoration(labelText: 'Label'),
        ),
        TextFormField(
          controller: hintController,
          textCapitalization: TextCapitalization.words,
          maxLength: 20,
          decoration: const InputDecoration(labelText: 'Hint'),
        ),
      ],
    );

    await Get.dialog(AlertDialog(
      title: const Text('Field Properties'),
      content: Form(
        key: formKey,
        child: Utils.isDrawerExpandable
            ? content
            : SizedBox(width: 450, child: content),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: _update,
          child: Text('update'.tr),
        ),
      ],
    ));
  }
}
