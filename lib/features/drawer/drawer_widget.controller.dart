import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';

import '../../../core/hive/hive.manager.dart';
import '../../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../main/main_screen.controller.dart';

enum HiveBoxFilter {
  all,
  archived,
  trash,
}

class DrawerMenuController extends GetxController with ConsoleMixin {
  // CONSTRUCTOR
  static DrawerMenuController get to => Get.find();

  // VARIABLES
  // maintain expansion tile state
  bool categoriesExpanded = true, tagsExpanded = true;

  // PROPERTIES
  final filterFavorites = false.obs;
  final filterProtected = false.obs;
  final filterTrashed = false.obs;
  final filterCategory = LisoItemCategory.none.obs;
  final filterTag = ''.obs;

  // GETTERS

  // Obtain used categories distinctly
  Set<String> get categories {
    if (HiveManager.items == null) return {};
    final Set<String> _categories = {};

    for (var e in HiveManager.items!.values) {
      _categories.add(e.category);
    }

    return _categories;
  }

  // Obtain used tags distinctly
  Set<String> get tags {
    if (HiveManager.items == null) return {};

    final _usedTags = HiveManager.items!.values
        .map((e) => e.tags.where((x) => x.isNotEmpty).toList())
        .toSet();

    final Set<String> _tags = {};

    if (_usedTags.isNotEmpty) {
      _tags.addAll(_usedTags.reduce((a, b) => a + b).toSet());
    }

    return _tags;
  }

  int get itemsCount =>
      HiveManager.items?.values.where((e) => !e.trashed).length ?? 0;

  int get favoriteCount =>
      HiveManager.items?.values.where((e) => e.favorite).length ?? 0;

  int get protectedCount =>
      HiveManager.items?.values.where((e) => e.protected).length ?? 0;

  int get trashedCount =>
      HiveManager.items?.values.where((e) => e.trashed).length ?? 0;

  // INIT

  // FUNCTIONS

  void filterFavoriteItems() async {
    filterFavorites.toggle();
    filterProtected.value = false;
    filterTrashed.value = false;
    filterTag.value = '';
    _done();
  }

  void filterProtectedItems() async {
    filterProtected.toggle();
    filterFavorites.value = false;
    filterTrashed.value = false;
    filterTag.value = '';
    _done();
  }

  void filterTrashedItems() async {
    filterTrashed.toggle();
    filterFavorites.value = false;
    filterProtected.value = false;
    filterTag.value = '';
    _done();
  }

  void filterAllItems() {
    _clearFilters();
    filterFavorites.value = false;
    filterProtected.value = false;
    filterTrashed.value = false;
    _done();
  }

  void filterByCategory(String category) {
    final _category = LisoItemCategory.values.byName(category);
    // if already selected, deselect
    filterCategory.value =
        _category == filterCategory.value ? LisoItemCategory.none : _category;
    filterTag.value = '';
    _done();
  }

  void filterByTag(String tag) {
    // if already selected, deselect
    if (tag == filterTag.value) tag = '';
    filterTag.value = tag;
    _done();
  }

  void _clearFilters() {
    filterCategory.value = LisoItemCategory.none;
    filterTag.value = '';
  }

  void files() async {
    Utils.adaptiveRouteOpen(name: Routes.s3Explorer);
  }

  void _done() async {
    // // delay for better Mobile UX
    // if (mainController.expandableDrawer) {
    //   await Future.delayed(500.milliseconds);
    // }

    MainScreenController.to.load();
    Get.back();
  }
}
