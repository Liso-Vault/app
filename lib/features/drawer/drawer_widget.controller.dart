import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/groups/groups.controller.dart';
import 'package:liso/features/joined_vaults/explorer/vault_explorer_screen.controller.dart';

import '../../core/hive/models/item.hive.dart';
import '../../core/persistence/persistence.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../categories/categories.controller.dart';
import '../general/remote_image.widget.dart';
import '../items/items.service.dart';
import '../joined_vaults/joined_vault.controller.dart';
import '../main/main_screen.controller.dart';
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
  final filterCategory = ''.obs;
  final filterTag = ''.obs;
  final filterSharedVaultId = ''.obs;

  // GETTERS

  Iterable<HiveLisoItem> get groupedItems => ItemsService.to.data.where(
        (e) {
          if (filterGroupId.value.isNotEmpty) {
            return e.groupId == filterGroupId.value;
          } else if (filterSharedVaultId.value.isNotEmpty) {
            return e.sharedVaultIds.contains(filterSharedVaultId.value);
          } else {
            console.error('error query');
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

  int get trashedCount =>
      groupedItems.where((e) => e.trashed && !e.deleted).length;

  int get deletedCount => groupedItems.where((e) => e.deleted).length;

  bool get filterAll =>
      !filterFavorites.value &&
      !filterProtected.value &&
      !filterTrashed.value &&
      !filterDeleted.value;

  List<Widget> get groupTiles => GroupsController.to.combined.map((group) {
        final count = ItemsService.to.data
            .where((item) => item.groupId == group.id && !item.deleted)
            .length;

        return ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(group.reservedName),
              if (count > 0) ...[
                Chip(label: Text(count.toString())),
              ],
            ],
          ),
          leading: const Icon(Iconsax.briefcase),
          selected: group.id == filterGroupId.value,
          onTap: () => filterByGroupId(group.id),
        );
      }).toList();

  List<Widget> get categoryTiles => CategoriesController.to.combined
          .where((e) => categories.contains(e.id))
          .map((category) {
        return ListTile(
          title: Text(category.reservedName),
          leading: Utils.categoryIcon(category.id),
          selected: category.id == filterCategory.value,
          onTap: () => filterByCategory(category.id),
        );
      }).toList();

  List<Widget> get sharedVaultsTiles =>
      SharedVaultsController.to.data.isNotEmpty
          ? SharedVaultsController.to.data.map(
              (vault) {
                final count = groupedItems
                    .where((item) => item.sharedVaultIds.contains(vault.docId))
                    .length;

                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(vault.name),
                      if (count > 0) ...[
                        Chip(label: Text(count.toString())),
                      ],
                    ],
                  ),
                  leading: vault.iconUrl.isEmpty
                      ? const Icon(Iconsax.share)
                      : RemoteImage(
                          url: vault.iconUrl,
                          width: 35,
                          alignment: Alignment.centerLeft,
                        ),
                  selected: vault.docId == filterSharedVaultId.value,
                  onTap: () => filterBySharedVaultId(vault.docId),
                );
              },
            ).toList()
          : [
              ListTile(
                title: const Text('Create'),
                leading: const Icon(LineIcons.plus),
                onTap: () => Utils.adaptiveRouteOpen(name: Routes.sharedVaults),
              ),
            ];

  List<Widget> get joinedVaultsTiles =>
      JoinedVaultsController.to.data.isNotEmpty
          ? JoinedVaultsController.to.data.map(
              (vault) {
                // TODO: extract vault and count items
                const count = 0;

                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(vault.name),
                      if (count > 0) ...[
                        Chip(label: Text(count.toString())),
                      ],
                    ],
                  ),
                  leading: vault.iconUrl.isEmpty
                      ? const Icon(Iconsax.share)
                      : RemoteImage(
                          url: vault.iconUrl,
                          width: 35,
                          alignment: Alignment.centerLeft,
                        ),
                  onTap: () {
                    VaultExplorerScreenController.vault = vault;
                    Utils.adaptiveRouteOpen(name: Routes.vaultExplorer);
                  },
                );
              },
            ).toList()
          : [
              ListTile(
                title: const Text('Join'),
                leading: const Icon(LineIcons.plus),
                onTap: () => Utils.adaptiveRouteOpen(name: Routes.joinedVaults),
              ),
            ];

  String get filterSharedVaultLabel {
    final vaults = SharedVaultsController.to.data
        .where((e) => e.docId == filterSharedVaultId.value);
    if (vaults.isEmpty) return '';
    return vaults.first.name;
  }

  String get filterGroupLabel {
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
    // if already selected, deselect
    if (vaultId == filterSharedVaultId.value) vaultId = '';
    filterSharedVaultId.value = vaultId;
    done();
  }

  void filterByCategory(String category) {
    // if already selected, deselect
    filterCategory.value = category == filterCategory.value ? '' : category;
    done();
  }

  void filterByTag(String tag) {
    // if already selected, deselect
    if (tag == filterTag.value) tag = '';
    filterTag.value = tag;
    done();
  }

  void filterFavoriteItems() async {
    filterFavorites.toggle();
    filterProtected.value = false;
    filterTrashed.value = false;
    filterDeleted.value = false;
    done();
  }

  void filterProtectedItems() async {
    filterProtected.toggle();
    filterFavorites.value = false;
    filterTrashed.value = false;
    filterDeleted.value = false;
    done();
  }

  void filterTrashedItems() async {
    filterTrashed.toggle();
    filterFavorites.value = false;
    filterProtected.value = false;
    filterDeleted.value = false;
    done();
  }

  void filterDeletedItems() async {
    filterDeleted.toggle();
    filterFavorites.value = false;
    filterProtected.value = false;
    filterTrashed.value = false;
    done();
  }

  void clearFilters() {
    filterCategory.value = '';
    filterTag.value = '';
    filterSharedVaultId.value = '';
    filterFavorites.value = false;
    filterProtected.value = false;
    filterTrashed.value = false;
    filterDeleted.value = false;
  }

  void files() async {
    Utils.adaptiveRouteOpen(
      name: Routes.s3Explorer,
      parameters: {'type': 'explorer'},
    );
  }

  void done() async {
    MainScreenController.to.load();
    if (Utils.isDrawerExpandable) Get.back();
  }
}
