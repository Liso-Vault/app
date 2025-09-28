import 'dart:convert';
import 'dart:typed_data';

import 'package:app_core/globals.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:liso/features/items/items.service.dart';

import '../../../core/hive/models/item.hive.dart';
import '../../../core/services/cipher.service.dart';
import '../../../core/utils/globals.dart';
import '../../files/storage.service.dart';
import '../../files/sync.service.dart';
import '../../menu/menu.item.dart';
import '../../search/search.delegate.dart';
import '../../shared_vaults/model/shared_vault.model.dart';

class VaultExplorerScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  static VaultExplorerScreenController get to => Get.find();
  static late SharedVault vault;

  // VARIABLES
  List<HiveLisoItem> items = const [];
  ItemsSearchDelegate? searchDelegate;
  final sortOrder = LisoItemSortOrder.dateModifiedDescending.obs;

  // PROPERTIES
  final data = <HiveLisoItem>[].obs;
  final busy = false.obs;

  // PROPERTIES

  // GETTERS
  List<ContextMenuItem> get menuItemsSort {
    final sortName = sortOrder.value.name;
    final ascending = sortName.contains('Ascending');

    final icon = Icon(
      ascending ? LineAwesome.sort_solid : LineAwesome.sort_down_solid,
    );

    return [
      ContextMenuItem(
        title: 'title'.tr,
        leading: Icon(Iconsax.text_outline, size: popupIconSize),
        trailing: sortName.contains('title') ? icon : null,
        onSelected: () {
          sortOrder.value = !sortName.contains('title') || ascending
              ? LisoItemSortOrder.titleDescending
              : LisoItemSortOrder.titleAscending;
        },
      ),
      ContextMenuItem(
        title: 'date_modified'.tr,
        leading: Icon(Iconsax.calendar_outline, size: popupIconSize),
        trailing: sortName.contains('dateModified') ? icon : null,
        onSelected: () {
          sortOrder.value = !sortName.contains('dateModified') || ascending
              ? LisoItemSortOrder.dateModifiedDescending
              : LisoItemSortOrder.dateModifiedAscending;
        },
      ),
      ContextMenuItem(
        title: 'date_created'.tr,
        leading: Icon(Iconsax.calendar_tick_outline, size: popupIconSize),
        trailing: sortName.contains('dateCreated') ? icon : null,
        onSelected: () {
          sortOrder.value = !sortName.contains('dateCreated') || ascending
              ? LisoItemSortOrder.dateCreatedDescending
              : LisoItemSortOrder.dateCreatedAscending;
        },
      ),
      ContextMenuItem(
        title: 'favorite'.tr,
        leading: Icon(Iconsax.heart_outline, size: popupIconSize),
        trailing: sortName.contains('favorite') ? icon : null,
        onSelected: () {
          sortOrder.value = !sortName.contains('favorite') || ascending
              ? LisoItemSortOrder.favoriteDescending
              : LisoItemSortOrder.favoriteAscending;
        },
      ),
      ContextMenuItem(
        title: 'protected'.tr,
        leading: Icon(Iconsax.lock_outline, size: popupIconSize),
        trailing: sortName.contains('protected') ? icon : null,
        onSelected: () {
          sortOrder.value = !sortName.contains('protected') || ascending
              ? LisoItemSortOrder.protectedDescending
              : LisoItemSortOrder.protectedAscending;
        },
      ),
    ];
  }

  // INIT
  @override
  void onInit() {
    init();
    super.onInit();
  }

  @override
  void onReady() {
    sortOrder.listen((order) => load());
    super.onReady();
  }

  @override
  void change(status) {
    busy.value = status.isLoading;
    super.change(status);
  }

  // FUNCTIONS
  void init() async {
    change(GetStatus.loading());
    // download vault file

    final result = await FileService.to.download(
      object: '$kDirShared/${vault.docId}.$kVaultExtension',
    );

    if (result.isLeft) {
      final message =
          'The shared vault file with ID: ${vault.docId} cannot be found';
      change(GetStatus.error(message));

      return UIUtils.showSimpleDialog(
        'Shared Vault File Not Found',
        message,
      );
    }

    // obtain cipher key
    final items_ =
        ItemsService.to.data.where((e) => e.identifier == vault.docId).toList();

    if (items_.isEmpty) {
      const message = 'Missing cipher key from vault';
      change(GetStatus.error(message));

      return UIUtils.showSimpleDialog(
        'Cipher Key Not Found',
        message,
      );
    }

    final fields_ =
        items_.first.fields.where((e) => e.identifier == 'key').toList();

    if (fields_.isEmpty) {
      const message = 'Missing cipher key from item field';
      change(GetStatus.error(message));

      return UIUtils.showSimpleDialog(
        'Cipher Key Not Found',
        message,
      );
    }

    // decrypt vault
    late Uint8List cipherKey;

    try {
      cipherKey = base64Decode(fields_.first.data.value!);
    } catch (e) {
      const message = 'Cipher key is broken or tampered';
      change(GetStatus.error(message));

      return UIUtils.showSimpleDialog(
        'Cipher Key Is Broken',
        message,
      );
    }

    final correctCipherKey = await CipherService.to.canDecrypt(
      result.right,
      cipherKey,
    );

    if (!correctCipherKey) {
      const message = 'Cipher key is incorrect';
      change(GetStatus.error(message));

      return UIUtils.showSimpleDialog(
        'Failed To Decrypt',
        message,
      );
    }

    final decryptedBytes = CipherService.to.decrypt(
      result.right,
      cipherKey: cipherKey,
    );

    // parse vault
    final vaultJson = jsonDecode(utf8.decode(decryptedBytes));
    // deserialize
    items = List<HiveLisoItem>.from(
      vaultJson.map((x) => HiveLisoItem.fromJson(x)),
    );

    console.info('imported items: ${items.length}');
    load();
  }

  void load() async {
    // --- SORT BY TITLE ---- //
    // descending
    if (sortOrder.value == LisoItemSortOrder.titleDescending) {
      items.sort((a, b) => b.title.compareTo(a.title));
    }

    // ascending
    if (sortOrder.value == LisoItemSortOrder.titleAscending) {
      items.sort((a, b) => a.title.compareTo(b.title));
    }

    // --- SORT BY TITLE ---- //
    // descending
    if (sortOrder.value == LisoItemSortOrder.categoryDescending) {
      items.sort((a, b) => b.category.compareTo(a.category));
    }

    // ascending
    if (sortOrder.value == LisoItemSortOrder.categoryAscending) {
      items.sort((a, b) => a.category.compareTo(b.category));
    }

    // --- SORT BY DATE MODIFIED ---- //
    // descending
    if (sortOrder.value == LisoItemSortOrder.dateModifiedDescending) {
      items.sort(
        (a, b) => b.metadata.updatedTime.compareTo(a.metadata.updatedTime),
      );
    }

    // ascending
    if (sortOrder.value == LisoItemSortOrder.dateModifiedAscending) {
      items.sort(
        (a, b) => a.metadata.updatedTime.compareTo(b.metadata.updatedTime),
      );
    }

    // --- SORT BY DATE CREATED ---- //
    // descending
    if (sortOrder.value == LisoItemSortOrder.dateCreatedDescending) {
      items.sort(
        (a, b) => b.metadata.createdTime.compareTo(a.metadata.createdTime),
      );
    }

    // ascending
    if (sortOrder.value == LisoItemSortOrder.dateCreatedAscending) {
      items.sort(
        (a, b) => a.metadata.createdTime.compareTo(b.metadata.createdTime),
      );
    }

    // --- SORT BY FAVORITE ---- //
    // descending
    if (sortOrder.value == LisoItemSortOrder.favoriteDescending) {
      items.sort((a, b) => b.favorite ? 1 : -1);
    }

    // ascending
    if (sortOrder.value == LisoItemSortOrder.favoriteAscending) {
      items.sort((a, b) => a.favorite ? 1 : -1);
    }

    // --- SORT BY PROTECTED ---- //
    // descending
    if (sortOrder.value == LisoItemSortOrder.protectedDescending) {
      items.sort((a, b) => b.protected ? 1 : -1);
    }

    // ascending
    if (sortOrder.value == LisoItemSortOrder.protectedAscending) {
      items.sort((a, b) => a.protected ? 1 : -1);
    }

    data.value = List.from(items);
    change(data.isEmpty ? GetStatus.empty() : GetStatus.success(null));
    // reload SearchDelegate to reflect
    searchDelegate?.reload(Get.context!);
  }

  void search() async {
    searchDelegate = ItemsSearchDelegate(
      items,
      joinedVaultItem: true,
    );

    await showSearch(
      context: Get.context!,
      delegate: searchDelegate!,
    );

    searchDelegate = null;
  }
}
