import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/models/item.hive.dart';

import '../../core/utils/globals.dart';
import '../drawer/drawer_widget.controller.dart';
import 'items.service.dart';

class ItemsController extends GetxController with ConsoleMixin, StateMixin {
  static ItemsController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final data = <HiveLisoItem>[].obs;
  final raw = <HiveLisoItem>[].obs;
  final sortOrder = LisoItemSortOrder.dateModifiedDescending.obs;

  // GETTERS

  bool get itemLimitReached => data.length >= limits.items;

  bool get protectedItemLimitReached =>
      data.where((e) => e.protected).length >= limits.protectedItems;

  // INIT
  @override
  void onInit() {
    sortOrder.listen((order) => load());
    // load();
    super.onInit();
  }

  // FUNCTIONS

  Future<void> load() async {
    change(GetStatus.loading());
    final drawerController = Get.find<DrawerMenuController>();
    raw.value = ItemsService.to.data;
    Iterable<HiveLisoItem> filteredItems = List.from(raw);

    // FILTER ITEMS WITH USERNAME / PASSWORDS ONLY
    if (isAutofill) {
      filteredItems = filteredItems.where(
          (e) => e.usernameFields.isNotEmpty || e.passwordFields.isNotEmpty);
    }

    if (drawerController.filterGroupId.value.isNotEmpty) {
      // FILTER BY GROUP
      filteredItems = filteredItems
          .where((e) => e.groupId == drawerController.filterGroupId.value);
    }

    if (drawerController.filterSharedVaultId.value.isNotEmpty) {
      // FILTER BY SHARED VAULT
      filteredItems = filteredItems.where((e) => e.sharedVaultIds
          .contains(drawerController.filterSharedVaultId.value));
    }

    // DELETE DUE TRASH ITEMS
    final itemsToDelete =
        filteredItems.where((e) => e.daysLeftToDelete <= 0 && e.trashed);

    if (itemsToDelete.isNotEmpty) {
      await ItemsService.to.hideleteItems(itemsToDelete);
    }

    // FILTER BY TOGGLE
    if (drawerController.filterAll) {
      filteredItems =
          filteredItems.where((e) => !e.trashed && !e.deleted && !e.trashed);
    } else if (drawerController.filterFavorites.value) {
      filteredItems =
          filteredItems.where((e) => e.favorite && !e.deleted && !e.trashed);
    } else if (drawerController.filterProtected.value) {
      filteredItems =
          filteredItems.where((e) => e.protected && !e.deleted && !e.trashed);
    } else if (drawerController.filterPasswordHealth.value) {
      filteredItems = filteredItems.where((e) =>
          (e.hasWeakPasswords || e.hasReusedPasswords) &&
          !e.deleted &&
          !e.trashed);
    } else if (drawerController.filterTrashed.value) {
      filteredItems = filteredItems.where((e) => e.trashed && !e.deleted);
    } else if (drawerController.filterDeleted.value) {
      filteredItems = filteredItems.where((e) => e.deleted);
    }

    // FILTER BY CATEGORY
    if (drawerController.filterCategory.value != '') {
      filteredItems = filteredItems.where(
        (e) => e.category == drawerController.filterCategory.value,
      );
    }

    // FILTER BY TAG
    if (drawerController.filterTag.isNotEmpty) {
      filteredItems = filteredItems.where(
        (e) => e.tags.contains(drawerController.filterTag.value),
      );
    }

    final sortedItems = filteredItems.toList();

    // --- SORT BY TITLE ---- //
    // descending
    if (sortOrder.value == LisoItemSortOrder.titleDescending) {
      sortedItems.sort((a, b) => b.title.compareTo(a.title));
    }

    // ascending
    if (sortOrder.value == LisoItemSortOrder.titleAscending) {
      sortedItems.sort((a, b) => a.title.compareTo(b.title));
    }

    // --- SORT BY TITLE ---- //
    // descending
    if (sortOrder.value == LisoItemSortOrder.categoryDescending) {
      sortedItems.sort((a, b) => b.category.compareTo(a.category));
    }

    // ascending
    if (sortOrder.value == LisoItemSortOrder.categoryAscending) {
      sortedItems.sort((a, b) => a.category.compareTo(b.category));
    }

    // --- SORT BY DATE MODIFIED ---- //
    // descending
    if (sortOrder.value == LisoItemSortOrder.dateModifiedDescending) {
      sortedItems.sort(
        (a, b) => b.metadata.updatedTime.compareTo(a.metadata.updatedTime),
      );
    }

    // ascending
    if (sortOrder.value == LisoItemSortOrder.dateModifiedAscending) {
      sortedItems.sort(
        (a, b) => a.metadata.updatedTime.compareTo(b.metadata.updatedTime),
      );
    }

    // --- SORT BY DATE CREATED ---- //
    // descending
    if (sortOrder.value == LisoItemSortOrder.dateCreatedDescending) {
      sortedItems.sort(
        (a, b) => b.metadata.createdTime.compareTo(a.metadata.createdTime),
      );
    }

    // ascending
    if (sortOrder.value == LisoItemSortOrder.dateCreatedAscending) {
      sortedItems.sort(
        (a, b) => a.metadata.createdTime.compareTo(b.metadata.createdTime),
      );
    }

    // --- SORT BY FAVORITE ---- //
    // descending
    if (sortOrder.value == LisoItemSortOrder.favoriteDescending) {
      sortedItems.sort((a, b) => b.favorite ? 1 : -1);
    }

    // ascending
    if (sortOrder.value == LisoItemSortOrder.favoriteAscending) {
      sortedItems.sort((a, b) => a.favorite ? 1 : -1);
    }

    // --- SORT BY PROTECTED ---- //
    // descending
    if (sortOrder.value == LisoItemSortOrder.protectedDescending) {
      sortedItems.sort((a, b) => b.protected ? 1 : -1);
    }

    // ascending
    if (sortOrder.value == LisoItemSortOrder.protectedAscending) {
      sortedItems.sort((a, b) => a.protected ? 1 : -1);
    }

    // load items
    data.value = sortedItems;
    change(data.isEmpty ? GetStatus.empty() : GetStatus.success(null));
  }
}
