import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/notifications/notifications.manager.dart';
import 'package:liso/core/services/authentication.service.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/utils/utils.dart';
import '../drawer/drawer_widget.controller.dart';
import '../menu/menu.item.dart';
import '../s3/s3.service.dart';
import '../search/search.delegate.dart';

class MainScreenController extends GetxController
    with StateMixin, ConsoleMixin, WindowListener {
  static MainScreenController get to => Get.find();

  // VARIABLES
  Timer? timeLockTimer;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final sortOrder = LisoItemSortOrder.dateModifiedDescending.obs;
  final persistence = Get.find<PersistenceService>();
  final upSyncing = false.obs;
  final downSyncing = false.obs;

  List<ContextMenuItem> get menuItemsCategory {
    return LisoItemCategory.values
        .where((e) => e.name != 'none')
        .toList()
        .map(
          (e) => ContextMenuItem(
            title: e.name.tr,
            leading: Utils.categoryIcon(
              LisoItemCategory.values.byName(e.name),
            ),
            onSelected: () {
              Utils.adaptiveRouteOpen(
                name: Routes.item,
                parameters: {'mode': 'add', 'category': e.name},
              );
            },
          ),
        )
        .toList();
  }

  ItemsSearchDelegate? searchDelegate;

  // PROPERTIES
  final data = <HiveLisoItem>[].obs;

  // GETTERS
  bool get syncing => upSyncing.value || downSyncing.value;

  List<ContextMenuItem> get menuItemsSort {
    final sortName = sortOrder.value.name;
    final ascending = sortName.contains('Ascending');

    final icon = Icon(
      ascending ? LineIcons.sortUpAscending : LineIcons.sortDownDescending,
    );

    return [
      ContextMenuItem(
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
      ContextMenuItem(
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
      ContextMenuItem(
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
      ContextMenuItem(
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
      ContextMenuItem(
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
      ContextMenuItem(
        title: 'protected'.tr,
        leading: const Icon(LineIcons.alternateShield),
        trailing: sortName.contains('protected') ? icon : null,
        onSelected: () {
          if (!sortName.contains('protected')) {
            sortOrder.value = LisoItemSortOrder.protectedDescending; // default
          } else {
            sortOrder.value = ascending
                ? LisoItemSortOrder.protectedDescending
                : LisoItemSortOrder.protectedAscending;
          }
        },
      ),
    ];
  }

  // INIT
  @override
  void onInit() {
    if (GetPlatform.isDesktop) {
      windowManager.addListener(this);
      windowManager.setPreventClose(true);
    }

    console.info('onInit');
    super.onInit();
  }

  @override
  void onReady() {
    downSync();
    _initAppLifeCycleEvents();
    sortOrder.listen((order) => _load());
    _load();
    // listen for sort order changes
    console.info('onReady');
    super.onReady();
  }

  @override
  void onClose() {
    if (GetPlatform.isDesktop) {
      windowManager.removeListener(this);
    }

    timeLockTimer?.cancel();
    super.onClose();
  }

  @override
  void onWindowClose() async {
    bool preventClosing = await windowManager.isPreventClose();
    final confirmClose = !Get.isDialogOpen! &&
        preventClosing &&
        persistence.changes.val > 0 &&
        persistence.sync.val;

    if (!confirmClose) return windowManager.destroy();

    final content = Text(
      'There are ${persistence.changes.val} unsynced changes you may want to sync first before exiting.',
    );

    Get.dialog(AlertDialog(
      title: const Text('Unsynced Changes'),
      content: Utils.isDrawerExpandable
          ? content
          : SizedBox(
              width: 600,
              child: content,
            ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: Get.back,
          style: TextButton.styleFrom(),
        ),
        TextButton(
          child: const Text('Force Close'),
          onPressed: () {
            if (GetPlatform.isDesktop) windowManager.destroy();
          },
        ),
      ],
    ));

    super.onWindowClose();
  }

  @override
  void onWindowResized() async {
    final size = await windowManager.getSize();
    persistence.windowWidth.val = size.width;
    persistence.windowHeight.val = size.height;
    console.warning('window resized: $size');
    super.onWindowResized();
  }

  // FUNCTIONS

  void reload() => _load();

  void _load() async {
    change(null, status: RxStatus.loading());
    final drawerController = Get.find<DrawerMenuController>();
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

    // load items
    data.value = items;
    change(null, status: data.isEmpty ? RxStatus.empty() : RxStatus.success());

    // reload SearchDelegate to reflect
    searchDelegate?.reload(Get.context!);
    // update drawer state
    drawerController.refresh();
  }

  void sync() {
    if (syncing) return;

    if (persistence.changes.val > 0) {
      upSync();
    } else {
      downSync();
    }
  }

  Future<void> downSync() async {
    downSyncing.value = true;
    await S3Service.to.downSync();
    downSyncing.value = false;
    _load();
  }

  Future<void> upSync() async {
    // make sure we are down synced before can up sync
    if (!S3Service.to.canUpSync) {
      await downSync();

      if (!S3Service.to.canUpSync) {
        return console.error('unable to upSync because downSync failed');
      }
    }

    upSyncing.value = true;
    final result = await S3Service.to.upSync();
    bool success = false;

    result.fold(
      (error) => UIUtils.showSimpleDialog(
        'Error Syncing',
        '$error > sync()',
      ),
      (response) => success = response,
    );

    if (!success) {
      upSyncing.value = false;
      return;
    }

    upSyncing.value = false;
    persistence.changes.val = 0;

    NotificationsManager.notify(
      title: 'Successfully Synced',
      body: 'Your vault just got updated.',
    );
  }

  void search() async {
    searchDelegate = ItemsSearchDelegate();

    await showSearch(
      context: Get.context!,
      delegate: searchDelegate!,
    );

    searchDelegate = null;
  }

  void onBoxChanged(BoxEvent event) async {
    console.info('box changed');
    // add change only if not a deleted event to prevent duplicates
    if (!event.deleted) {
      persistence.changes.val++;
      // use the static getter to avoid not reloading bug
      MainScreenController.to.reload();
      console.info('load');
    }
  }

  void _initAppLifeCycleEvents() {
    // auto-lock after app is inactive
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      console.warning(msg!);

      if (msg == AppLifecycleState.resumed.toString()) {
        timeLockTimer?.cancel();

        if (AuthenticationService.to.isAuthenticated &&
            Globals.wallet == null) {
          Get.toNamed(Routes.unlock);
        }
      } else if (msg == AppLifecycleState.inactive.toString()) {
        // lock after <duration> of inactivity
        if (Globals.timeLockEnabled) {
          final timeLock = persistence.timeLockDuration.val.seconds;
          timeLockTimer = Timer.periodic(timeLock, (timer) {
            Globals.wallet = null;
            timer.cancel();
          });
        }
      }

      return Future.value(msg);
    });
  }
}
