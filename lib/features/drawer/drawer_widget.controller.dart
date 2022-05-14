import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../../../core/hive/hive.manager.dart';
import '../../../core/utils/globals.dart';
import '../../core/firebase/firestore.service.dart';
import '../../core/hive/models/item.hive.dart';
import '../../core/services/persistence.service.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../main/main_screen.controller.dart';
import '../s3/s3.service.dart';

enum HiveBoxFilter {
  all,
  archived,
  trash,
}

class DrawerMenuController extends GetxController with ConsoleMixin {
  // CONSTRUCTOR
  static DrawerMenuController get to => Get.find();

  // VARIABLES
  final persistence = Get.find<PersistenceService>();

  // maintain expansion tile state
  bool networksExpanded = false,
      groupsExpanded = false,
      tagsExpanded = false,
      categoriesExpanded = false,
      toolsExpanded = false;

  // PROPERTIES
  final filterGroupIndex = 0.obs;
  final filterFavorites = false.obs;
  final filterProtected = false.obs;
  final filterTrashed = false.obs;
  final filterCategory = LisoItemCategory.none.obs;
  final filterTag = ''.obs;

  // GETTERS
  Iterable<HiveLisoItem> get groupedItems => HiveManager.items == null
      ? []
      : HiveManager.items!.values.where(
          (e) => e.group == filterGroupIndex.value,
        );

  // Obtain used categories distinctly
  Set<String> get categories {
    final Set<String> _categories = {};

    for (var e in groupedItems) {
      _categories.add(e.category);
    }

    return _categories;
  }

  // Obtain used tags distinctly
  Set<String> get tags {
    final _usedTags = groupedItems
        .map((e) => e.tags.where((x) => x.isNotEmpty).toList())
        .toSet();

    final Set<String> _tags = {};

    if (_usedTags.isNotEmpty) {
      _tags.addAll(_usedTags.reduce((a, b) => a + b).toSet());
    }

    return _tags;
  }

  int get itemsCount =>
      groupedItems.where((e) => !e.trashed && !e.trashed).length;

  int get favoriteCount =>
      groupedItems.where((e) => e.favorite && !e.trashed).length;

  int get protectedCount =>
      groupedItems.where((e) => e.protected && !e.trashed).length;

  int get trashedCount => groupedItems.where((e) => e.trashed).length;

  bool get filterAll =>
      !filterFavorites.value &&
      !filterProtected.value &&
      !filterTrashed.value &&
      filterTag.isEmpty &&
      filterCategory.value == LisoItemCategory.none;

  List<Widget> get groupTiles =>
      persistence.groupsMap.map((Map<String, dynamic> e) {
        return ListTile(
          title: Text(e['name']),
          leading: const Icon(LineIcons.dotCircle),
          selected: e['index'] == filterGroupIndex.value,
          onTap: () {
            filterGroupIndex.value = e['index'];
            done();
          },
        );
      }).toList();

  // INIT

  // FUNCTIONS

  void filterFavoriteItems() async {
    filterFavorites.toggle();
    filterProtected.value = false;
    filterTrashed.value = false;
    filterTag.value = '';
    done();
  }

  void filterProtectedItems() async {
    filterProtected.toggle();
    filterFavorites.value = false;
    filterTrashed.value = false;
    filterTag.value = '';
    done();
  }

  void filterTrashedItems() async {
    filterTrashed.toggle();
    filterFavorites.value = false;
    filterProtected.value = false;
    filterTag.value = '';
    done();
  }

  void filterAllItems() {
    clearFilters();
    done();
  }

  void filterByCategory(String category) {
    final _category = LisoItemCategory.values.byName(category);
    // if already selected, deselect
    filterCategory.value =
        _category == filterCategory.value ? LisoItemCategory.none : _category;
    filterTag.value = '';
    done();
  }

  void filterByTag(String tag) {
    // if already selected, deselect
    if (tag == filterTag.value) tag = '';
    filterTag.value = tag;
    done();
  }

  void clearFilters() {
    filterCategory.value = LisoItemCategory.none;
    filterTag.value = '';
    filterFavorites.value = false;
    filterProtected.value = false;
    filterTrashed.value = false;
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
