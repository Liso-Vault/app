import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/general/selector.sheet.dart';

import '../../core/utils/utils.dart';
import 'drawer/drawer_widget.controller.dart';

class MainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainScreenController());
    Get.lazyPut(() => DrawerWidgetController());
  }
}

class MainScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static MainScreenController get to => Get.find();

  // VARIABLES
  Timer? timer;
  final sortOrder = LisoItemSortOrder.dateModifiedDescending.obs;
  final drawerController = Get.find<DrawerWidgetController>();

  // PROPERTIES
  final data = <HiveLisoItem>[].obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    _initAppLifeCycleEvents();
    Utils.setDisplayMode();
    _listen();
    _initRouter();

    super.onInit();
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

    _load();
  }

  void _listen() {
    // console.warning(
    //   'Event: key: ${event.key}, value: ${event.value}, deleted: ${event.deleted}',
    // );

    // if (event.deleted) {
    //   data.removeWhere((e) => e.key == event.key);
    // }

    // watch hive box changes
    HiveManager.items?.watch().listen((_) => _load());
    HiveManager.archived?.watch().listen((_) => _load());
    HiveManager.trash?.watch().listen((_) => _load());

    // listen for sort order changes
    sortOrder.listen((order) => _load());
  }

  void reload() => _load();

  void _load() async {
    change(null, status: RxStatus.loading());

    List<HiveLisoItem> items = [];

    // FILTER BY BOX
    if (drawerController.boxFilter == HiveBoxFilter.all) {
      items = HiveManager.items!.values.toList();
    } else if (drawerController.boxFilter == HiveBoxFilter.archived) {
      items = HiveManager.archived!.values.toList();
    } else if (drawerController.boxFilter == HiveBoxFilter.trash) {
      items = HiveManager.trash!.values.toList();
    }

    // FILTER FAVORITES
    if (drawerController.filterFavorites.value) {
      items = items.where((e) => e.favorite).toList();
    }

    // FILTER BY CATEGORY
    if (drawerController.filterCategory != null) {
      items = items
          .where((e) => e.category == drawerController.filterCategory!.name)
          .toList();
    }

    // FILTER BY TAG
    if (drawerController.filterTag.isNotEmpty) {
      items = items
          .where((e) => e.tags.contains(drawerController.filterTag))
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

    // load items
    data.value = items;
    change(null, status: data.isEmpty ? RxStatus.empty() : RxStatus.success());
  }

  void add() async {
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
    SelectorSheet(
      items: [
        SelectorItem(
          title: 'title'.tr,
          leading: const Icon(LineIcons.sortAlphabeticalDown),
          onSelected: () {
            if (sortOrder.value == LisoItemSortOrder.titleAscending) {
              sortOrder.value = LisoItemSortOrder.titleDescending;
            } else if (sortOrder.value == LisoItemSortOrder.titleDescending) {
              sortOrder.value = LisoItemSortOrder.titleAscending;
            } else {
              sortOrder.value = LisoItemSortOrder.titleDescending;
            }
          },
        ),
        SelectorItem(
          title: 'category'.tr,
          leading: const Icon(LineIcons.sitemap),
          onSelected: () {
            if (sortOrder.value == LisoItemSortOrder.categoryAscending) {
              sortOrder.value = LisoItemSortOrder.categoryDescending;
            } else if (sortOrder.value ==
                LisoItemSortOrder.categoryDescending) {
              sortOrder.value = LisoItemSortOrder.categoryAscending;
            } else {
              sortOrder.value = LisoItemSortOrder.categoryDescending;
            }
          },
        ),
        SelectorItem(
          title: 'date_modified'.tr,
          leading: const Icon(LineIcons.calendar),
          onSelected: () {
            if (sortOrder.value == LisoItemSortOrder.dateModifiedAscending) {
              sortOrder.value = LisoItemSortOrder.dateModifiedDescending;
            } else if (sortOrder.value ==
                LisoItemSortOrder.dateModifiedDescending) {
              sortOrder.value = LisoItemSortOrder.dateModifiedAscending;
            } else {
              sortOrder.value = LisoItemSortOrder.dateModifiedDescending;
            }
          },
        ),
        SelectorItem(
          title: 'date_created'.tr,
          leading: const Icon(LineIcons.calendarAlt),
          onSelected: () {
            if (sortOrder.value == LisoItemSortOrder.dateCreatedAscending) {
              sortOrder.value = LisoItemSortOrder.dateCreatedDescending;
            } else if (sortOrder.value ==
                LisoItemSortOrder.dateCreatedDescending) {
              sortOrder.value = LisoItemSortOrder.dateCreatedAscending;
            } else {
              sortOrder.value = LisoItemSortOrder.dateCreatedDescending;
            }
          },
        ),
        SelectorItem(
          title: 'favorite'.tr,
          leading: const Icon(LineIcons.heart),
          onSelected: () {
            if (sortOrder.value == LisoItemSortOrder.favoriteAscending) {
              sortOrder.value = LisoItemSortOrder.favoriteDescending;
            } else if (sortOrder.value ==
                LisoItemSortOrder.favoriteDescending) {
              sortOrder.value = LisoItemSortOrder.favoriteAscending;
            } else {
              sortOrder.value = LisoItemSortOrder.favoriteDescending;
            }
          },
        ),
      ],
    ).show();
  }
}
