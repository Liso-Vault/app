import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/features/groups/groups.controller.dart';
import 'package:liso/features/items/items.controller.dart';

import '../../core/hive/models/item.hive.dart';
import '../../core/persistence/persistence.dart';
import '../../core/utils/utils.dart';
import '../categories/categories.controller.dart';
import '../shared_vaults/shared_vault.controller.dart';

enum HiveBoxFilter {
  all,
  archived,
  trash,
}

class DrawerMenuController extends GetxController with ConsoleMixin {
  // CONSTRUCTOR
  static DrawerMenuController get to => Get.find();

  // VARIABLES
  final persistence = Get.find<Persistence>();

  // maintain expansion tile state
  bool networksExpanded = false,
      groupsExpanded = false,
      sharedVaultsExpanded = false,
      joinedVaultsExpanded = false,
      tagsExpanded = false,
      categoriesExpanded = false,
      toolsExpanded = false;

  // PROPERTIES
  final filterGroupId = 'personal'.obs;
  final filterFavorites = false.obs;
  final filterProtected = false.obs;
  final filterTrashed = false.obs;
  final filterDeleted = false.obs;
  final filterPasswordHealth = false.obs;
  final filterCategory = ''.obs;
  final filterTag = ''.obs;
  final filterSharedVaultId = ''.obs;

  // GETTERS

  Iterable<HiveLisoItem> get groupedItems => ItemsController.to.raw.where(
        (e) {
          if (filterGroupId.value.isNotEmpty) {
            return e.groupId == filterGroupId.value;
          } else if (filterSharedVaultId.value.isNotEmpty) {
            return e.sharedVaultIds.contains(filterSharedVaultId.value);
          } else {
            return false;
          }
        },
      );

  // Obtain used categories distinctly
  Set<String> get categories {
    final Set<String> categories = {};

    for (var e in groupedItems) {
      categories.add(e.category);
    }

    return categories;
  }

  // Obtain used tags distinctly
  Set<String> get tags {
    final usedTags = groupedItems
        .where((e) => !e.trashed && !e.deleted)
        .map((e) => e.tags.where((x) => x.isNotEmpty).toList())
        .toSet();

    final Set<String> tags = {};

    if (usedTags.isNotEmpty) {
      tags.addAll(usedTags.reduce((a, b) => a + b).toSet());
    }

    return tags;
  }

  int get itemsCount =>
      groupedItems.where((e) => !e.trashed && !e.deleted).length;

  int get favoriteCount =>
      groupedItems.where((e) => e.favorite && !e.trashed && !e.deleted).length;

  int get protectedCount =>
      groupedItems.where((e) => e.protected && !e.trashed && !e.deleted).length;

  int get fragilePasswordCount => groupedItems
      .where((e) =>
          !e.trashed &&
          !e.deleted &&
          (e.hasWeakPasswords || e.hasReusedPasswords))
      .length;

  int get trashedCount =>
      groupedItems.where((e) => e.trashed && !e.deleted).length;

  int get deletedCount => groupedItems.where((e) => e.deleted).length;

  bool get filterAll =>
      !filterFavorites.value &&
      !filterProtected.value &&
      !filterTrashed.value &&
      !filterDeleted.value &&
      !filterPasswordHealth.value;

  List<Widget> get categoryTiles => CategoriesController.to.combined
          .where((e) => categories.contains(e.id))
          .map((category) {
        return Obx(
          () => ListTile(
            title: Text(category.reservedName, overflow: TextOverflow.ellipsis),
            leading: Utils.categoryIcon(category.id),
            selected: category.id == filterCategory.value,
            onTap: () => filterByCategory(category.id),
          ),
        );
      }).toList();

  List<Widget> get tagTiles => tags
      .map(
        (e) => Obx(
          () => ListTile(
            title: Text(e, overflow: TextOverflow.ellipsis),
            leading: const Icon(Iconsax.tag),
            onTap: () => filterByTag(e),
            selected: e == filterTag.value,
          ),
        ),
      )
      .toList();

  String get filterSharedVaultLabel {
    final vaults = SharedVaultsController.to.data
        .where((e) => e.docId == filterSharedVaultId.value);
    if (vaults.isEmpty) return '';
    return vaults.first.name;
  }

  String get filterGroupLabel {
    if (filterGroupId.value.isEmpty) return 'all'.tr;
    final groups =
        GroupsController.to.combined.where((e) => e.id == filterGroupId.value);
    if (groups.isEmpty) return '';
    return groups.first.reservedName;
  }

  String get filterCategoryLabel {
    final categories = CategoriesController.to.combined
        .where((e) => e.id == filterCategory.value);
    if (categories.isEmpty) return '';
    return categories.first.reservedName;
  }

  String get filterToggleLabel {
    if (filterAll) return 'All';
    if (filterFavorites.value) return 'Favorites';
    if (filterProtected.value) return 'Protected';
    if (filterTrashed.value) return 'Trashed';
    if (filterDeleted.value) return 'Deleted';
    if (filterPasswordHealth.value) return 'Password Health';
    return 'Unknown';
  }

  String get filterTagLabel => filterTag.value;

  // INIT

  // FUNCTIONS

  void filterAllItems() {
    clearFilters();
    done();
  }

  void filterByGroupId(String groupId) {
    filterGroupId.value = groupId;
    done();
  }

  void filterBySharedVaultId(String vaultId) {
    if (vaultId == filterSharedVaultId.value) vaultId = '';
    filterSharedVaultId.value = vaultId;
    done();
  }

  void filterByCategory(String category) {
    filterCategory.value = category == filterCategory.value ? '' : category;
    done();
  }

  void filterByTag(String tag) {
    if (tag == filterTag.value) tag = '';
    filterTag.value = tag;
    done();
  }

  void filterFavoriteItems() async {
    filterFavorites.toggle();
    filterProtected.value = false;
    filterTrashed.value = false;
    filterDeleted.value = false;
    filterPasswordHealth.value = false;
    done();
  }

  void filterProtectedItems() async {
    filterProtected.toggle();
    filterFavorites.value = false;
    filterTrashed.value = false;
    filterDeleted.value = false;
    filterPasswordHealth.value = false;
    done();
  }

  void filterTrashedItems() async {
    filterTrashed.toggle();
    filterFavorites.value = false;
    filterProtected.value = false;
    filterDeleted.value = false;
    filterPasswordHealth.value = false;
    done();
  }

  void filterDeletedItems() async {
    filterDeleted.toggle();
    filterFavorites.value = false;
    filterProtected.value = false;
    filterTrashed.value = false;
    filterPasswordHealth.value = false;
    done();
  }

  void filterPasswordHealthItems() async {
    filterPasswordHealth.toggle();
    filterDeleted.value = false;
    filterFavorites.value = false;
    filterProtected.value = false;
    filterTrashed.value = false;
    done();
  }

  void clearFilters() {
    filterGroupId.value = 'personal';
    filterCategory.value = '';
    filterTag.value = '';
    filterSharedVaultId.value = '';
    filterFavorites.value = false;
    filterProtected.value = false;
    filterTrashed.value = false;
    filterDeleted.value = false;
    filterPasswordHealth.value = false;
  }

  void done() async {
    await ItemsController.to.load();
    if (Utils.isDrawerExpandable) Get.back();
  }
}
