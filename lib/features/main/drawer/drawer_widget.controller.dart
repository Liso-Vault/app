import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';

import '../../../core/hive/hive.manager.dart';
import '../../../core/utils/globals.dart';
import '../main_screen.controller.dart';

enum HiveBoxFilter {
  all,
  archived,
  trash,
}

class DrawerWidgetController extends GetxController with ConsoleMixin {
  // CONSTRUCTOR
  static DrawerWidgetController get to => Get.find();

  // VARIABLES
  // maintain expansion tile expanded state
  bool categoriesExpanded = true, tagsExpanded = true;
  LisoItemCategory? filterCategory;
  String filterTag = '';

  // PROPERTIES
  final filterFavorites = false.obs;
  final boxFilter = HiveBoxFilter.all.obs;

  // GETTERS

  // Obtain used categories distinctly
  Set<String> get categories {
    final Set<String> _categories = {};

    for (var e in HiveManager.items!.values) {
      _categories.add(e.category);
    }

    return _categories;
  }

  // Obtain used tags distinctly
  Set<String> get tags {
    final _usedTags = HiveManager.items!.values
        .map((e) => e.tags.where((x) => x.isNotEmpty).toList())
        .toSet();

    final Set<String> _tags = {};

    if (_usedTags.isNotEmpty) {
      _tags.addAll(_usedTags.reduce((a, b) => a + b).toSet());
    }

    return _tags;
  }

  String get itemsCount =>
      HiveManager.items!.isEmpty ? '' : HiveManager.items!.length.toString();

  String get favoriteCount => HiveManager.items!.isEmpty
      ? ''
      : HiveManager.items!.values.where((e) => e.favorite).length.toString();

  String get archivedCount => HiveManager.archived!.isEmpty
      ? ''
      : HiveManager.archived!.length.toString();

  String get trashCount =>
      HiveManager.trash!.isEmpty ? '' : HiveManager.trash!.length.toString();

  // FUNCTIONS

  // void filterFavoritesSwitch(bool? value) async {
  //   filterFavorites.value = value!;
  //   filterTag = '';
  //   MainScreenController.to.reload();
  //   // delay until switch animation is finished
  //   await Future.delayed(300.milliseconds);
  //   Get.back();
  // }

  void filterFavoriteItems() async {
    filterFavorites.toggle();
    filterTag = '';
    MainScreenController.to.reload();
    Get.back();
  }

  void filterAllItems() {
    _clearFilters();
    filterFavorites.value = false;
    boxFilter.value = HiveBoxFilter.all;
    reload();
  }

  void filterArchivedItems() {
    _clearFilters();
    boxFilter.value = HiveBoxFilter.archived;
    reload();
  }

  void filterTrashItems() {
    _clearFilters();
    boxFilter.value = HiveBoxFilter.trash;
    reload();
  }

  void filterByCategory(String category) {
    LisoItemCategory? _category = LisoItemCategory.values.byName(category);
    // if already selected, deselect
    if (_category == filterCategory) _category = null;
    filterCategory = _category;
    filterTag = '';
    reload();
  }

  void filterByTag(String tag) {
    // if already selected, deselect
    if (tag == filterTag) tag = '';
    filterTag = tag;
    reload();
  }

  void _clearFilters() {
    filterCategory = null;
    filterTag = '';
  }

  void reload() {
    MainScreenController.to.reload();
    Get.back();
  }
}
