import 'dart:async';
import 'dart:convert';

import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:liso/core/form_fields/richtext.field.dart';
import 'package:liso/core/hive/models/app_domain.hive.dart';
import 'package:liso/core/hive/models/category.hive.dart';
import 'package:liso/core/hive/models/field.hive.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/categories/categories.controller.dart';
import 'package:liso/features/files/storage.service.dart';
import 'package:liso/features/general/section.widget.dart';
import 'package:liso/features/joined_vaults/explorer/vault_explorer_screen.controller.dart';
import 'package:liso/features/tags/tags_input.controller.dart';
// import 'package:otp/otp.dart';
import 'package:random_string_generator/random_string_generator.dart';
import 'package:simple_totp_auth/simple_totp_auth.dart';
import 'package:uuid/uuid.dart';

import '../../core/hive/models/metadata/metadata.hive.dart';
import '../../core/persistence/persistence.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../drawer/drawer_widget.controller.dart';
import '../json_viewer/json_viewer.screen.dart';
import '../menu/menu.button.dart';
import '../menu/menu.item.dart';
import '../shared_vaults/shared_vault.controller.dart';
import 'items.controller.dart';
import 'items.service.dart';

class ItemScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  static ItemScreenController get to => Get.find();

  // VARIABLES
  HiveLisoItem? item;
  late HiveLisoItem originalItem;
  Timer? otpTimer;

  final formKey = GlobalKey<FormState>();
  final menuKey = GlobalKey<FormState>();
  final mode = gParameters['mode'];
  final joinedVaultItem = gParameters['joinedVaultItem'] == 'true';
  final titleController = TextEditingController();
  final tagsController = Get.put(TagsInputController());

  final protectedCategories = [
    LisoItemCategory.cryptoWallet,
    LisoItemCategory.cashCard,
    LisoItemCategory.bankAccount,
    LisoItemCategory.apiCredential,
    LisoItemCategory.email,
    LisoItemCategory.login,
    LisoItemCategory.password,
    LisoItemCategory.wirelessRouter,
    LisoItemCategory.encryption,
    LisoItemCategory.otp,
  ].map((e) => e.name);

  final iconUrl = ''.obs;
  final widgets = <Widget>[].obs;

  // PROPERTIES
  final favorite = false.obs;
  final protected = false.obs;
  final reserved = false.obs;
  final groupId = DrawerMenuController.to.filterGroupId.value.obs;
  final category = gParameters['category']!.obs;
  final attachments = <String>[].obs;
  final sharedVaultIds = <String>[].obs;
  final editMode = (gParameters['mode'] != 'view').obs;
  final reorderMode = false.obs;
  final otpCode = ''.obs;
  final otpRemainingSeconds = 0.obs;
  final otpURI = ''.obs;
  final uris = <String>[].obs;
  final appIds = <String>[].obs;

  // GETTERS

  List<HiveLisoField> get parseFields => widgets.map((e) {
        final formWidget = (e as dynamic).children.first.child.child;
        final field = formWidget.field as HiveLisoField;

        if (formWidget?.value is Map<String, dynamic>) {
          field.data.extra = formWidget.value;
        } else {
          field.data.value = formWidget?.value ?? '';
        }

        return field;
      }).toList();

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
        leading: Icon(Iconsax.copy_outline, size: popupIconSize),
        onSelected: () => Utils.copyToClipboard(item!.significant.values.first),
      ),
      // if (item.categoryObject == LisoItemCategory.cryptoWallet) ...[
      //   ContextMenuItem(
      //     title: 'QR Code',
      //     leading: const Icon(Iconsax.barcode),
      //     onSelected: () {},
      //   ),
      // ]
      if (editMode.value) ...[
        ContextMenuItem(
          title: reorderMode.value ? 'done_re_order'.tr : 're_order_fields'.tr,
          leading: Icon(Icons.drag_indicator, size: popupIconSize),
          onSelected: reorderMode.toggle,
        ),
      ],
      ContextMenuItem(
        title: 'details'.tr,
        leading: Icon(Iconsax.code_outline, size: popupIconSize),
        onSelected: () => Get.to(() => JSONViewerScreen(data: item!.toJson())),
      ),
      if (kDebugMode) ...[
        ContextMenuItem(
          title: 'force_close'.tr,
          leading: Icon(Iconsax.slash_outline, size: popupIconSize),
          onSelected: Get.back,
        ),
      ],
      ContextMenuItem(
        title: 'need_help'.tr,
        leading: Icon(Iconsax.message_question_outline, size: popupIconSize),
        onSelected: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
      ),
    ];
  }

  List<ContextMenuItem> get titleMenuItems {
    return [
      ContextMenuItem(
        title: 'copy'.tr,
        leading: Icon(Iconsax.copy_outline, size: popupIconSize),
        onSelected: () => Utils.copyToClipboard(titleController.text),
      ),
      ContextMenuItem(
        title: 'clear'.tr,
        leading: Icon(LineAwesome.times_solid, size: popupIconSize),
        onSelected: titleController.clear,
      ),
    ];
  }

  List<ContextMenuItem> get menuFieldItems => [
        ContextMenuItem(
          title: 'text_field'.tr,
          leading: Icon(Iconsax.text_outline, size: popupIconSize),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.textField.name,
              data: HiveLisoFieldData(label: 'Text Field'),
            );

            widgets.add(
              _buildFieldWidget(
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: field.widget,
                ),
                widgets.length,
              ),
            );
          },
        ),
        ContextMenuItem(
          title: 'textarea_field'.tr,
          leading: Icon(Iconsax.note_text_outline, size: popupIconSize),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.textArea.name,
              data: HiveLisoFieldData(label: 'TextArea Field'),
            );

            widgets.add(
              _buildFieldWidget(
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: field.widget,
                ),
                widgets.length,
              ),
            );
          },
        ),
        ContextMenuItem(
          title: 'password_field'.tr,
          leading: Icon(Iconsax.password_check_outline, size: popupIconSize),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.password.name,
              data: HiveLisoFieldData(label: 'Password Field'),
            );

            widgets.add(
              _buildFieldWidget(
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: field.widget,
                ),
                widgets.length,
              ),
            );
          },
        ),
        ContextMenuItem(
          title: 'phone_field'.tr,
          leading: Icon(LineAwesome.phone_solid, size: popupIconSize),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.phone.name,
              data: HiveLisoFieldData(label: 'Phone Field'),
            );

            widgets.add(
              _buildFieldWidget(
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: field.widget,
                ),
                widgets.length,
              ),
            );
          },
        ),
        ContextMenuItem(
          title: 'pin_field'.tr,
          leading: Icon(Iconsax.code_outline, size: popupIconSize),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.pin.name,
              data: HiveLisoFieldData(label: 'PIN Field'),
            );

            widgets.add(
              _buildFieldWidget(
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: field.widget,
                ),
                widgets.length,
              ),
            );
          },
        ),
        ContextMenuItem(
          title: 'totp_field'.tr,
          leading: Icon(Iconsax.shield_outline, size: popupIconSize),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.totp.name,
              data: HiveLisoFieldData(label: 'TOTP Field'),
            );

            widgets.add(
              _buildFieldWidget(
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: field.widget,
                ),
                widgets.length,
              ),
            );
          },
        ),
        ContextMenuItem(
          title: 'url_field'.tr,
          leading: Icon(Iconsax.link_outline, size: popupIconSize),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.url.name,
              data: HiveLisoFieldData(label: 'URL Field'),
            );

            widgets.add(
              _buildFieldWidget(
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: field.widget,
                ),
                widgets.length,
              ),
            );
          },
        ),
        ContextMenuItem(
          title: 'date_field'.tr,
          leading: Icon(Iconsax.calendar_outline, size: popupIconSize),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.date.name,
              data: HiveLisoFieldData(label: 'Date Field'),
            );

            widgets.add(
              _buildFieldWidget(
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: field.widget,
                ),
                widgets.length,
              ),
            );
          },
        ),
        ContextMenuItem(
          title: 'email_field'.tr,
          leading: Icon(Iconsax.message_outline, size: popupIconSize),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.email.name,
              data: HiveLisoFieldData(label: 'email_field'.tr),
            );

            widgets.add(
              _buildFieldWidget(
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: field.widget,
                ),
                widgets.length,
              ),
            );
          },
        ),
        ContextMenuItem(
          title: 'number_field'.tr,
          leading: Icon(Icons.numbers, size: popupIconSize),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.number.name,
              data: HiveLisoFieldData(label: 'number_field'.tr),
            );

            widgets.add(
              _buildFieldWidget(
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: field.widget,
                ),
                widgets.length,
              ),
            );
          },
        ),
        ContextMenuItem(
          title: 'passport_field'.tr,
          leading: Icon(Iconsax.card_outline, size: popupIconSize),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.passport.name,
              data: HiveLisoFieldData(label: 'passport_field'.tr),
            );

            widgets.add(
              _buildFieldWidget(
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: field.widget,
                ),
                widgets.length,
              ),
            );
          },
        ),
        ContextMenuItem(
          title: 'toggle_field'.tr,
          leading: Icon(Icons.toggle_on, size: popupIconSize),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.toggle.name,
              data: HiveLisoFieldData(label: 'toggle'.tr),
            );

            widgets.add(
              _buildFieldWidget(
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: field.widget,
                ),
                widgets.length,
              ),
            );
          },
        ),
        ContextMenuItem(
          title: 'address_field'.tr,
          leading: Icon(Iconsax.location_outline, size: popupIconSize),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.address.name,
              data: HiveLisoFieldData(label: 'address_field'.tr),
            );

            widgets.add(
              _buildFieldWidget(
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: field.widget,
                ),
                widgets.length,
              ),
            );
          },
        ),
        ContextMenuItem(
          title: 'section'.tr,
          leading: Icon(Icons.text_fields, size: popupIconSize),
          onSelected: () {
            final field = HiveLisoField(
              identifier: const Uuid().v4(),
              reserved: false,
              type: LisoFieldType.section.name,
              data: HiveLisoFieldData(label: 'section'.tr),
            );

            widgets.add(
              _buildFieldWidget(
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: field.widget,
                ),
                widgets.length,
              ),
            );
          },
        ),
      ];

  List<ContextMenuItem> get menuItemsChangeIcon {
    return [
      ContextMenuItem(
        title: 'change'.tr,
        leading: Icon(Iconsax.gallery_outline, size: popupIconSize),
        onSelected: _pickIcon,
      ),
      if (iconUrl.value.isNotEmpty) ...[
        ContextMenuItem(
          title: 'remove'.tr,
          leading: Icon(Iconsax.trash_outline, size: popupIconSize),
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
        onDeleted: editMode.value ? () => sharedVaultIds.remove(vaultId) : null,
      );
    }).toList();

    final menuItems = SharedVaultsController.to.data
        .where((e) => !sharedVaultIds.contains(e.docId))
        .map((vault) {
      return ContextMenuItem(
        title: vault.name,
        value: vault.docId,
        leading: Icon(Iconsax.share_outline,
            size: popupIconSize), // TODO: RemoteImage
        onSelected: () {
          if (sharedVaultIds.contains(vault.docId)) return;
          sharedVaultIds.add(vault.docId);
        },
      );
    }).toList();

    if (menuItems.isNotEmpty && editMode.value) {
      chips.add(ContextMenuButton(
        menuItems,
        padding: EdgeInsets.zero,
        child: ActionChip(
          label: const Icon(Iconsax.add_circle_outline, size: 20),
          onPressed: () {},
        ),
      ));
    }

    return chips;
  }

  List<Widget> get attachmentChips {
    // TODO: attachment cache
    List<Widget> chips = attachments.map<Widget>((attachment) {
      final itemsFound = FileService.to.rootInfo.value.data.objects.where(
        (e) => e.etag == attachment,
      );

      if (itemsFound.isEmpty) {
        return Chip(
          label: Text('file_not_found'.tr),
          onDeleted:
              editMode.value ? () => attachments.remove(attachment) : null,
        );
      }

      return Chip(
        label: Text(itemsFound.first.name),
        onDeleted: editMode.value ? () => attachments.remove(attachment) : null,
      );
    }).toList();

    if (editMode.value) {
      chips.add(ActionChip(
        label: const Icon(Iconsax.add_circle_outline, size: 20),
        onPressed: attach,
      ));
    }

    return chips;
    // return [];
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
    } else if (mode == 'saved_autofill') {
      await _populateSavedAutofillItem();
    }

    originalItem = HiveLisoItem.fromJson(item!.toJson());
    _populateItem();
    change(GetStatus.success(null));
    // re-populate widgets
    editMode.listen((value) => _populateItem());
    if (category.value == LisoItemCategory.otp.name) generateOTP();
    super.onInit();
  }

  @override
  void onClose() {
    otpTimer?.cancel();
    super.onClose();
  }

  // FUNCTIONS
  void generateOTP() async {
    final secret =
        item!.fields.firstWhere((e) => e.identifier == 'secret').data.value!;

    void updateOTP() {
      if (editMode.value) return;
      final totp = TOTP(secret: secret);
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      otpRemainingSeconds.value = totp.interval - (currentTime % totp.interval);
      otpCode.value = totp.now();
      otpURI.value =
          totp.generateOTPAuthURI(issuer: config.name, account: item!.title);
    }

    updateOTP();

    otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateOTP();
    });
  }

  Future<void> _populateSavedAutofillItem() async {
    var fields = categoryObject.fields;

    final paramDomain = gParameters['app_domain']!;
    final appDomain = HiveAppDomain.fromJson(jsonDecode(paramDomain));

    appIds.value = appDomain.appIds;
    uris.value = appDomain.uris;

    fields = fields.map((e) {
      if (e.identifier == 'website') {
        if (appDomain.uris.isNotEmpty) {
          e.data.value = appDomain.uris.first.toString();
        }
      } else if (e.identifier == 'username') {
        e.data.value = gParameters['username'];
      } else if (e.identifier == 'password') {
        e.data.value = gParameters['password'];
      }

      return e;
    }).toList();

    item = HiveLisoItem(
      identifier: const Uuid().v4(),
      category: category.value,
      iconUrl: appDomain.iconUrl,
      title: gParameters['title']!,
      fields: fields,
      tags: ['saved'],
      favorite: false,
      protected: true,
      metadata: await HiveMetadata.get(),
      groupId: groupId.value,
      appIds: appDomain.appIds,
      uris: uris,
    );
  }

  Future<void> _populateGeneratedItem() async {
    final value = gParameters['value'];
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
      protected: true,
      metadata: await HiveMetadata.get(),
      groupId: groupId.value,
    );
  }

  void _loadItem() {
    if (!joinedVaultItem) {
      final hiveKey = gParameters['hiveKey'].toString();
      item = ItemsService.to.box!.get(int.parse(hiveKey))!;
    } else {
      final identifier = gParameters['identifier'].toString();
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
    appIds.value = item!.appIds == null ? [] : List.from(item!.appIds!);
    uris.value = item!.uris == null ? [] : List.from(item!.uris!);
    _buildFieldWidgets();
  }

  Widget _buildFieldWidget(Widget widget, int index) {
    return Row(
      key: Key(const Uuid().v4()),
      children: [
        Expanded(child: widget),
        Obx(
          () => Visibility(
            visible: editMode.value && reorderMode.value,
            child: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_indicator),
            ),
          ),
        )
      ],
    );
  }

  void _buildFieldWidgets() {
    // remove complicated OTP fields
    if (item!.category == LisoItemCategory.otp.name) {
      item!.fields.removeWhere(
        (e) => ['interval', 'length', 'algorithm', 'google']
            .contains(e.identifier),
      );
    }

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
            widget = Section(text: (field.sectionLabel).toUpperCase());
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
                Section(text: field.data.label!),
                // STREET 1
                if (street1.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  GestureDetector(
                    onSecondaryTap: () => Utils.copyToClipboard(street1),
                    child: InkWell(
                      onLongPress: () => Utils.copyToClipboard(street1),
                      child: TextFormField(
                        initialValue: street1,
                        enabled: false,
                        decoration: InputDecoration(labelText: 'street_1'.tr),
                      ),
                    ),
                  ),
                ],
                if (street2.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  GestureDetector(
                    onSecondaryTap: () => Utils.copyToClipboard(street2),
                    child: InkWell(
                      onLongPress: () => Utils.copyToClipboard(street2),
                      child: TextFormField(
                        initialValue: street2,
                        enabled: false,
                        decoration: InputDecoration(labelText: 'street_2'.tr),
                      ),
                    ),
                  ),
                ],
                if (city.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  GestureDetector(
                    onSecondaryTap: () => Utils.copyToClipboard(city),
                    child: InkWell(
                      onLongPress: () => Utils.copyToClipboard(city),
                      child: TextFormField(
                        initialValue: city,
                        enabled: false,
                        decoration: InputDecoration(labelText: 'city'.tr),
                      ),
                    ),
                  ),
                ],
                if (state.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  GestureDetector(
                    onSecondaryTap: () => Utils.copyToClipboard(state),
                    child: InkWell(
                      onLongPress: () => Utils.copyToClipboard(state),
                      child: TextFormField(
                        initialValue: state,
                        enabled: false,
                        decoration:
                            InputDecoration(labelText: 'state_province'.tr),
                      ),
                    ),
                  ),
                ],
                if (zip.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  GestureDetector(
                    onSecondaryTap: () => Utils.copyToClipboard(zip),
                    child: InkWell(
                      onLongPress: () => Utils.copyToClipboard(zip),
                      child: TextFormField(
                        initialValue: zip,
                        enabled: false,
                        decoration: InputDecoration(labelText: 'zip_code'.tr),
                      ),
                    ),
                  ),
                ],
                if (country.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  GestureDetector(
                    onSecondaryTap: () => Utils.copyToClipboard(country),
                    child: InkWell(
                      onLongPress: () => Utils.copyToClipboard(country),
                      child: TextFormField(
                        initialValue: country,
                        enabled: false,
                        decoration: InputDecoration(labelText: 'country'.tr),
                      ),
                    ),
                  ),
                ],
              ],
            );
          } else {
            final obscured = (field.type == LisoFieldType.password.name ||
                field.type == LisoFieldType.mnemonicSeed.name ||
                field.type == LisoFieldType.pin.name);

            final obscuredRx = obscured.obs;

            final strength = PasswordStrengthChecker.checkStrength(
              field.data.value!,
            );

            final isPasswordField =
                !kNonPasswordFieldIds.contains(field.identifier);

            // add a quick copy value feature when tapped
            widget = GestureDetector(
              onSecondaryTap: () =>
                  Utils.copyToClipboard(field.data.value ?? ''),
              child: InkWell(
                onLongPress: () =>
                    Utils.copyToClipboard(field.data.value ?? ''),
                onTap: obscuredRx.value ? obscuredRx.toggle : null,
                child: Obx(
                  () => TextFormField(
                    initialValue: field.data.value,
                    enabled: false,
                    obscureText: obscuredRx.value,
                    minLines: 1,
                    maxLines: obscuredRx.value ? 1 : 10,
                    decoration: InputDecoration(
                      labelText: field.data.label,
                      hintText: field.data.hint,
                      helperText: limits.passwordHealth &&
                              isPasswordField &&
                              obscured &&
                              field.data.value!.isNotEmpty
                          ? AppUtils.strengthName(strength).toUpperCase()
                          : null,
                      helperStyle: TextStyle(
                        color: AppUtils.strengthColor(strength),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }

        widget = Padding(
          padding: const EdgeInsets.only(top: 15),
          child: widget,
        );

        return _buildFieldWidget(widget, e.key);
      },
    ).toList();
  }

  Future<void> _loadTemplate() async {
    final drawerController = Get.find<DrawerMenuController>();
    // final protected_ = drawerController.filterProtected.value ||
    //     protectedCategories.contains(category.value);

    item = HiveLisoItem(
      identifier: const Uuid().v4(),
      category: category.value,
      title: '',
      fields: categoryObject.fields,
      favorite: drawerController.filterFavorites.value,
      // protected: protected_,
      metadata: await HiveMetadata.get(),
      groupId: drawerController.filterGroupId.value,
    );
  }

  void add() async {
    if (!formKey.currentState!.validate()) return;
    if (!editMode.value) return console.error('not in edit mode');

    // items limit
    if (ItemsController.to.itemLimitReached) {
      return Utils.adaptiveRouteOpen(
        name: Routes.upgrade,
        parameters: {
          'title': 'Items Limit Reached',
          'body':
              'Maximum items of ${limits.items} limit reached. Upgrade to Pro to unlock unlimited items features',
        },
      );
    }

    // protected items limit
    if (protected.value && ItemsController.to.protectedItemLimitReached) {
      return Utils.adaptiveRouteOpen(
        name: Routes.upgrade,
        parameters: {
          'title': 'Protected Items',
          'body':
              'Maximum protected items of ${limits.protectedItems} limit reached. Upgrade to Pro to unlock unlimited protected items feature.',
        },
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
      appIds: appIds,
      uris: uris,
    );

    await ItemsService.to.box!.add(newItem);
    AppPersistence.to.changes.val++;
    ItemsController.to.load();
    DrawerMenuController.to.update();
    UIUtils.requestReview();
    Get.backLegacy();

    // if (isAutofill) {
    //   AutofillService().onSaveComplete();
    // }
  }

  void edit() async {
    if (!formKey.currentState!.validate()) return;
    if (!editMode.value) return console.error('not in edit mode');

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
    item!.appIds = appIds;
    item!.uris = uris;
    await item!.save();

    console.wtf('appIds: $appIds');

    AppPersistence.to.changes.val++;
    ItemsController.to.load();
    DrawerMenuController.to.update();
    UIUtils.requestReview();
    Get.backLegacy();
  }

  void onProtectedChanged(bool? value) {
    // protected items limit
    if (value! && ItemsController.to.protectedItemLimitReached) {
      Utils.adaptiveRouteOpen(
        name: Routes.upgrade,
        parameters: {
          'title': 'Protected Items',
          'body':
              'Maximum protected items of ${limits.protectedItems} limit reached. Upgrade to Pro to unlock unlimited protected items feature.',
        },
      );

      return;
    }

    protected.value = value;
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
    final iconController = TextEditingController(text: item!.iconUrl);

    void save() async {
      if (!formKey.currentState!.validate()) return;
      iconUrl.value = iconController.text;
      Get.backLegacy();
    }

    final content = TextFormField(
      controller: iconController,
      autofocus: true,
      keyboardType: TextInputType.url,
      validator: (data) =>
          data!.isEmpty || GetUtils.isURL(data) ? null : 'Invalid URL',
      autovalidateMode: AutovalidateMode.onUserInteraction,
      autofillHints: const [AutofillHints.url],
      decoration: const InputDecoration(
        labelText: 'Icon URL',
        hintText: 'https://images.com/icon.png',
      ),
    );

    Get.dialog(AlertDialog(
      title: const Text('Custom Icon'),
      content: Form(
        key: formKey,
        child: isSmallScreen ? content : SizedBox(width: 450, child: content),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
        TextButton(onPressed: save, child: Text('save'.tr)),
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
      appIds: item!.appIds,
      uris: item!.uris,
    );

    // convert to json string for absolute equality check
    bool hasChanges = updatedItem.toJsonString() != originalItem.toJsonString();

    if (hasChanges) {
      const dialogContent = Text('You have unsaved changes');

      await Get.dialog(AlertDialog(
        title: const Text('Unsaved Changes'),
        content: isSmallScreen
            ? dialogContent
            : const SizedBox(width: 450, child: dialogContent),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              hasChanges = false;
              Get.backLegacy();
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
      name: AppRoutes.attachments,
      parameters: {'attachments': attachments.join(',')},
    );

    if (attachments_ == null) return;
    attachments.value = attachments_;
  }

  Future<void> showFieldProperties(dynamic formWidget) async {
    final field = formWidget.children.first.child.child.field;
    final formKey = GlobalKey<FormState>();
    final labelController = TextEditingController(text: field.data.label);
    final hintController = TextEditingController(text: field.data.hint);

    void update() async {
      if (!formKey.currentState!.validate()) return;
      field.data.label = labelController.text;
      field.data.hint = hintController.text;
      Get.backLegacy();
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
        child: isSmallScreen ? content : SizedBox(width: 450, child: content),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: update,
          child: Text('update'.tr),
        ),
      ],
    ));
  }
}
