import 'dart:async';

import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/item/items.service.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/categories/categories.controller.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/utils/ui_utils.dart';
import '../../core/utils/utils.dart';
import '../drawer/drawer_widget.controller.dart';
import '../groups/groups.controller.dart';
import '../menu/menu.item.dart';
import '../s3/s3.service.dart';
import '../search/search.delegate.dart';

class MainScreenController extends GetxController
    with StateMixin, ConsoleMixin, WindowListener {
  static MainScreenController get to => Get.find();

  // VARIABLES
  Timer? timeLockTimer;
  ItemsSearchDelegate? searchDelegate;
  final sortOrder = LisoItemSortOrder.dateModifiedDescending.obs;
  final persistence = Get.find<Persistence>();

  List<ContextMenuItem> get menuItemsCategory {
    return CategoriesController.to.combined
        .map(
          (e) => ContextMenuItem(
            title: e.reservedName,
            leading: Utils.categoryIcon(e.id, color: themeColor),
            onSelected: () => Utils.adaptiveRouteOpen(
              name: Routes.item,
              parameters: {'mode': 'add', 'category': e.id},
            ),
          ),
        )
        .toList();
  }

  // PROPERTIES
  final data = <HiveLisoItem>[].obs;

  // GETTERS
  List<ContextMenuItem> get menuItems {
    return [
      ContextMenuItem(
        title: 'sync'.tr,
        leading: const Icon(Iconsax.cloud_change),
        onSelected: S3Service.to.sync,
      ),
    ];
  }

  List<ContextMenuItem> get menuItemsSort {
    final sortName = sortOrder.value.name;
    final ascending = sortName.contains('Ascending');

    final icon = Icon(
      ascending ? LineIcons.sortUpAscending : LineIcons.sortDownDescending,
    );

    return [
      ContextMenuItem(
        title: 'title'.tr,
        leading: const Icon(Iconsax.text),
        trailing: sortName.contains('title') ? icon : null,
        onSelected: () {
          sortOrder.value = !sortName.contains('title') || ascending
              ? LisoItemSortOrder.titleDescending
              : LisoItemSortOrder.titleAscending;
        },
      ),
      ContextMenuItem(
        title: 'category'.tr,
        leading: const Icon(Iconsax.category),
        trailing: sortName.contains('category') ? icon : null,
        onSelected: () {
          sortOrder.value = !sortName.contains('category') || ascending
              ? LisoItemSortOrder.categoryDescending
              : LisoItemSortOrder.categoryAscending;
        },
      ),
      ContextMenuItem(
        title: 'date_modified'.tr,
        leading: const Icon(Iconsax.calendar),
        trailing: sortName.contains('dateModified') ? icon : null,
        onSelected: () {
          sortOrder.value = !sortName.contains('dateModified') || ascending
              ? LisoItemSortOrder.dateModifiedDescending
              : LisoItemSortOrder.dateModifiedAscending;
        },
      ),
      ContextMenuItem(
        title: 'date_created'.tr,
        leading: const Icon(Iconsax.calendar_tick),
        trailing: sortName.contains('dateCreated') ? icon : null,
        onSelected: () {
          sortOrder.value = !sortName.contains('dateCreated') || ascending
              ? LisoItemSortOrder.dateCreatedDescending
              : LisoItemSortOrder.dateCreatedAscending;
        },
      ),
      ContextMenuItem(
        title: 'favorite'.tr,
        leading: const Icon(Iconsax.heart),
        trailing: sortName.contains('favorite') ? icon : null,
        onSelected: () {
          sortOrder.value = !sortName.contains('favorite') || ascending
              ? LisoItemSortOrder.favoriteDescending
              : LisoItemSortOrder.favoriteAscending;
        },
      ),
      ContextMenuItem(
        title: 'protected'.tr,
        leading: const Icon(Iconsax.lock),
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
    if (GetPlatform.isDesktop && !GetPlatform.isWeb) {
      windowManager.addListener(this);
      windowManager.setPreventClose(true);
    }

    console.info('onInit');
    super.onInit();
  }

  @override
  void onReady() {
    _initAppLifeCycleEvents();
    sortOrder.listen((order) => load());
    Future.delayed(5.seconds).then((value) => _updateBuildNumber());
    console.info('onReady');
    super.onReady();
  }

  @override
  void onClose() {
    if (GetPlatform.isDesktop && !GetPlatform.isWeb) {
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
          : SizedBox(width: 450, child: content),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
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

  void init() async {
    load();

    // others
  }

  void onItemsUpdated() {
    persistence.changes.val++;
    load();
  }

  void search() async {
    searchDelegate = ItemsSearchDelegate(ItemsService.to.data);
    await showSearch(context: Get.context!, delegate: searchDelegate!);
    searchDelegate = null;
  }

  Future<void> load() async {
    GroupsController.to.load();
    CategoriesController.to.load();

    change(null, status: RxStatus.loading());
    final drawerController = DrawerMenuController.to;
    var items = ItemsService.to.data;

    // FILTER BY GROUP
    items = items
        .where((e) => e.groupId == drawerController.filterGroupId.value)
        .toList();

    if (drawerController.filterSharedVaultId.value.isNotEmpty) {
      // FILTER BY SHARED VAULT
      items = items
          .where((e) => e.sharedVaultIds
              .contains(drawerController.filterSharedVaultId.value))
          .toList();
    }

    // DELETE DUE TRASH ITEMS
    final itemsToDelete = items.where(
      (e) => e.daysLeftToDelete <= 0 && e.trashed,
    );

    if (itemsToDelete.isNotEmpty) {
      await ItemsService.to.hidelete(itemsToDelete);
    }

    // FILTER BY TOGGLE
    if (drawerController.filterAll) {
      items =
          items.where((e) => !e.trashed && !e.deleted && !e.trashed).toList();
    } else if (drawerController.filterFavorites.value) {
      items =
          items.where((e) => e.favorite && !e.deleted && !e.trashed).toList();
    } else if (drawerController.filterProtected.value) {
      items =
          items.where((e) => e.protected && !e.deleted && !e.trashed).toList();
    } else if (drawerController.filterTrashed.value) {
      items = items.where((e) => e.trashed && !e.deleted).toList();
    } else if (drawerController.filterDeleted.value) {
      items = items.where((e) => e.deleted).toList();
    }

    // FILTER BY CATEGORY
    if (drawerController.filterCategory.value != '') {
      items = items
          .where((e) => e.category == drawerController.filterCategory.value)
          .toList();
    }

    // FILTER BY TAG
    if (drawerController.filterTag.isNotEmpty) {
      items = items
          .where((e) => e.tags.contains(drawerController.filterTag.value))
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
    drawerController.refresh(); // update drawer state
  }

  void _initAppLifeCycleEvents() {
    // auto-lock after app is inactive
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      console.warning(msg!);

      if (msg == AppLifecycleState.resumed.toString()) {
        timeLockTimer?.cancel();

        if (WalletService.to.isSaved && !WalletService.to.isReady) {
          Get.toNamed(Routes.unlock);
        }
      } else if (msg == AppLifecycleState.inactive.toString()) {
        // lock after <duration> of inactivity
        if (Globals.timeLockEnabled) {
          final timeLock = persistence.timeLockDuration.val.seconds;
          timeLockTimer = Timer.periodic(timeLock, (timer) {
            WalletService.to.reset();
            timer.cancel();
          });
        }
      }

      return Future.value(msg);
    });
  }

  void _updateBuildNumber() async {
    persistence.lastBuildNumber.val = int.parse(
      Globals.metadata!.app.buildNumber,
    );
  }

  void emptyTrash() {
    void _empty() async {
      Get.back();
      final trashedKeys = ItemsService.to.data.where((e) => e.trashed);
      await ItemsService.to.hidelete(trashedKeys);
      load();

      UIUtils.showSnackBar(
        title: 'Empty Trash',
        message: 'Your trash is now emptied',
      );
    }

    const dialogContent = Text(
      'Are you sure you want to empty the trash?',
    );

    Get.dialog(AlertDialog(
      title: const Text('Empty Trash'),
      content: Utils.isDrawerExpandable
          ? dialogContent
          : const SizedBox(
              width: 450,
              child: dialogContent,
            ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: _empty,
          child: const Text('Empty Trash'),
        ),
      ],
    ));
  }

  void showSeed() async {
    // prompt password from unlock screen
    final unlocked = await Get.toNamed(
          Routes.unlock,
          parameters: {'mode': 'password_prompt'},
        ) ??
        false;

    if (!unlocked) return;

    Utils.adaptiveRouteOpen(
      name: Routes.seed,
      parameters: {'mode': 'display'},
    );
  }
}
