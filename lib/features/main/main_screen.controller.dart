import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/form_fields/password.field.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/general/selector.sheet.dart';

import '../../core/form_fields/pin.field.dart';
import '../../core/utils/utils.dart';
import '../search/search.delegate.dart';
import 'drawer/drawer_widget.controller.dart';

class MainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainScreenController());
    Get.lazyPut(() => DrawerWidgetController());

    // GET WIDGETS
    Get.create(() => PasswordFormFieldController());
    Get.create(() => PINFormFieldController());
  }
}

class MainScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static MainScreenController get to => Get.find();

  // VARIABLES
  Timer? timer;
  final sortOrder = LisoItemSortOrder.dateModifiedDescending.obs;
  final drawerController = Get.find<DrawerWidgetController>();
  ItemsSearchDelegate? searchDelegate;
  StreamSubscription? itemsSubscription,
      archivedSubscription,
      trashSubscription;

  // PROPERTIES
  final data = <HiveLisoItem>[].obs;

  // GETTERS

  // INIT
  @override
  void onInit() async {
    _initAppLifeCycleEvents();
    Utils.setDisplayMode();
    _initRouter();
    console.info('onInit');
    super.onInit();
  }

  @override
  void onReady() {
    // listen for sort order changes
    sortOrder.listen((order) => _load());
    _watchBoxes();
    console.info('onReady');
    super.onReady();
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  // FUNCTIONS
  // TODO: use getx router implementation
  void _initRouter() async {
    // show welcome screen if not authenticated
    if (!(await LisoManager.authenticated())) {
      await Get.toNamed(Routes.welcome);
      await Get.toNamed(Routes.createPassword);
    } else {
      if (encryptionKey == null) {
        await Get.toNamed(Routes.unlock);
      }
    }

    console.info('_initRouter');
    _load();
  }

  void _watchBoxes() {
    // console.warning(
    //   'Event: key: ${event.key}, value: ${event.value}, deleted: ${event.deleted}',
    // );

    // if (event.deleted) {
    //   data.removeWhere((e) => e.key == event.key);
    // }

    // watch hive box changes
    if (HiveManager.items != null && !HiveManager.items!.isOpen) {
      return console.error('hive boxes are not open');
    }

    itemsSubscription = HiveManager.items?.watch().listen((_) => _load());
    archivedSubscription = HiveManager.archived?.watch().listen((_) => _load());
    trashSubscription = HiveManager.trash?.watch().listen((_) => _load());
  }

  void unwatchBoxes() {
    itemsSubscription?.cancel();
    archivedSubscription?.cancel();
    trashSubscription?.cancel();
  }

  void reload() => _load();

  void _load() async {
    change(null, status: RxStatus.loading());

    List<HiveLisoItem> items = [];

    // FILTER BY BOX
    if (drawerController.boxFilter.value == HiveBoxFilter.all) {
      items = HiveManager.items!.values.toList();
    } else if (drawerController.boxFilter.value == HiveBoxFilter.archived) {
      items = HiveManager.archived!.values.toList();
    } else if (drawerController.boxFilter.value == HiveBoxFilter.trash) {
      items = HiveManager.trash!.values.toList();
    }

    // FILTER FAVORITES
    if (drawerController.filterFavorites.value) {
      items = items.where((e) => e.favorite).toList();
    }

    // FILTER PROTECTED
    if (drawerController.filterProtected.value) {
      items = items.where((e) => e.protected).toList();
    }

    // FILTER BY CATEGORY
    if (drawerController.filterCategory() != LisoItemCategory.none) {
      items = items
          .where((e) => e.category == drawerController.filterCategory().name)
          .toList();
    }

    // FILTER BY TAG
    if (drawerController.filterTag.isNotEmpty) {
      items = items
          .where((e) => e.tags.contains(drawerController.filterTag()))
          .toList();
    }

    // --- SORT BY TITLE ---- //
    // descending
    if (sortOrder.value == LisoItemSortOrder.titleDescending) {
      items.sort(
        (a, b) => b.title.compareTo(a.title),
      );
    }

    // ascending
    if (sortOrder.value == LisoItemSortOrder.titleAscending) {
      items.sort(
        (a, b) => a.title.compareTo(b.title),
      );
    }

    // --- SORT BY TITLE ---- //
    // descending
    if (sortOrder.value == LisoItemSortOrder.categoryDescending) {
      items.sort(
        (a, b) => b.category.compareTo(a.category),
      );
    }

    // ascending
    if (sortOrder.value == LisoItemSortOrder.categoryAscending) {
      items.sort(
        (a, b) => a.category.compareTo(b.category),
      );
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
      items.sort(
        (a, b) => b.favorite ? 1 : -1,
      );
    }

    // ascending
    if (sortOrder.value == LisoItemSortOrder.favoriteAscending) {
      items.sort(
        (a, b) => a.favorite ? 1 : -1,
      );
    }

    // --- SORT BY PROTECTED ---- //
    // descending
    if (sortOrder.value == LisoItemSortOrder.protectedDescending) {
      items.sort(
        (a, b) => b.protected ? 1 : -1,
      );
    }

    // ascending
    if (sortOrder.value == LisoItemSortOrder.protectedAscending) {
      items.sort(
        (a, b) => a.protected ? 1 : -1,
      );
    }

    // load items
    data.value = items;
    change(null, status: data.isEmpty ? RxStatus.empty() : RxStatus.success());
  }

  void add() async {
    if (drawerController.filterCategory() != LisoItemCategory.none) {
      return Get.toNamed(
        Routes.item,
        parameters: {
          'mode': 'add',
          'category': drawerController.filterCategory().name
        },
      );
    }

    SelectorSheet(
      items: LisoItemCategory.values
          .map((e) => e.name)
          .map((e) => SelectorItem(
                title: e.tr,
                leading: Utils.categoryIcon(
                  LisoItemCategory.values.byName(e),
                ),
                onSelected: () => Get.toNamed(
                  Routes.item,
                  parameters: {'mode': 'add', 'category': e},
                ),
              ))
          .toList(),
    ).show();
  }

  void _initAppLifeCycleEvents() {
    // auto-lock after app is inactive
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      console.warning(msg!);

      if (msg == AppLifecycleState.resumed.toString()) {
        timer?.cancel();

        if (await LisoManager.authenticated() && encryptionKey == null) {
          Get.toNamed(Routes.unlock);
        }
      } else if (msg == AppLifecycleState.inactive.toString()) {
        // lock after <duration> of inactivity
        if (timeLockEnabled) {
          final timeLock =
              PersistenceController.to.timeLockDuration.val.seconds;
          timer = Timer.periodic(timeLock, (timer) {
            encryptionKey = null;
            timer.cancel();
          });
        }
      }

      return Future.value(msg);
    });
  }

  void showSortSheet() {
    final sortName = sortOrder.value.name;
    final ascending = sortName.contains('Ascending');

    final icon = Icon(
      ascending ? LineIcons.sortUpAscending : LineIcons.sortDownDescending,
    );

    SelectorSheet(
      items: [
        SelectorItem(
          title: 'title'.tr,
          leading: const Icon(LineIcons.font),
          trailing: sortName.contains('title') ? icon : null,
          onSelected: () {
            if (!sortName.contains('title')) {
              sortOrder.value = LisoItemSortOrder.titleDescending; // default
            } else {
              sortOrder.value = ascending
                  ? LisoItemSortOrder.titleDescending
                  : LisoItemSortOrder.titleAscending;
            }
          },
        ),
        SelectorItem(
          title: 'category'.tr,
          leading: const Icon(LineIcons.sitemap),
          trailing: sortName.contains('category') ? icon : null,
          onSelected: () {
            if (!sortName.contains('category')) {
              sortOrder.value = LisoItemSortOrder.categoryDescending; // default
            } else {
              sortOrder.value = ascending
                  ? LisoItemSortOrder.categoryDescending
                  : LisoItemSortOrder.categoryAscending;
            }
          },
        ),
        SelectorItem(
          title: 'date_modified'.tr,
          leading: const Icon(LineIcons.calendar),
          trailing: sortName.contains('dateModified') ? icon : null,
          onSelected: () {
            if (!sortName.contains('dateModified')) {
              sortOrder.value =
                  LisoItemSortOrder.dateModifiedDescending; // default
            } else {
              sortOrder.value = ascending
                  ? LisoItemSortOrder.dateModifiedDescending
                  : LisoItemSortOrder.dateModifiedAscending;
            }
          },
        ),
        SelectorItem(
          title: 'date_created'.tr,
          leading: const Icon(LineIcons.calendarAlt),
          trailing: sortName.contains('dateCreated') ? icon : null,
          onSelected: () {
            if (!sortName.contains('dateCreated')) {
              sortOrder.value =
                  LisoItemSortOrder.dateCreatedDescending; // default
            } else {
              sortOrder.value = ascending
                  ? LisoItemSortOrder.dateCreatedDescending
                  : LisoItemSortOrder.dateCreatedAscending;
            }
          },
        ),
        SelectorItem(
          title: 'favorite'.tr,
          leading: const FaIcon(FontAwesomeIcons.heart),
          trailing: sortName.contains('favorite') ? icon : null,
          onSelected: () {
            if (!sortName.contains('favorite')) {
              sortOrder.value = LisoItemSortOrder.favoriteDescending; // default
            } else {
              sortOrder.value = ascending
                  ? LisoItemSortOrder.favoriteDescending
                  : LisoItemSortOrder.favoriteAscending;
            }
          },
        ),
        SelectorItem(
          title: 'protected'.tr,
          leading: const Icon(LineIcons.alternateShield),
          trailing: sortName.contains('protected') ? icon : null,
          onSelected: () {
            if (!sortName.contains('protected')) {
              sortOrder.value =
                  LisoItemSortOrder.protectedDescending; // default
            } else {
              sortOrder.value = ascending
                  ? LisoItemSortOrder.protectedDescending
                  : LisoItemSortOrder.protectedAscending;
            }
          },
        ),
      ],
    ).show();
  }
}
