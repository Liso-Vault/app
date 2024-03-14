import 'dart:async';
import 'dart:io';

import 'package:app_core/globals.dart';
import 'package:app_core/services/notifications.service.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/autofill/autofill.service.dart';
import 'package:liso/features/categories/categories.controller.dart';
import 'package:liso/features/items/items.controller.dart';
import 'package:liso/features/items/items.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:path/path.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/liso/liso_paths.dart';
import '../../core/persistence/persistence.secret.dart';
import '../../core/utils/utils.dart';
import '../drawer/drawer_widget.controller.dart';
import '../files/sync.service.dart';
import '../groups/groups.controller.dart';
import '../menu/menu.item.dart';
import '../search/search.delegate.dart';

class MainScreenController extends GetxController with ConsoleMixin {
  static MainScreenController get to => Get.find();

  // VARIABLES
  DateTime? lastInactiveTime;
  ItemsSearchDelegate? searchDelegate;

  final autofill = AutofillService();
  final persistence = Get.find<Persistence>();
  final itemsController = Get.find<ItemsController>();
  final drawerController = Get.find<DrawerMenuController>();

  List<ContextMenuItem> get menuItemsCategory {
    return CategoriesController.to.combined
        .map(
          (e) => ContextMenuItem(
            title: e.reservedName,
            leading: AppUtils.categoryIcon(
              e.id,
              color: themeColor,
              size: popupIconSize,
            ),
            onSelected: () => Utils.adaptiveRouteOpen(
              name: AppRoutes.item,
              parameters: {'mode': 'add', 'category': e.id},
            ),
          ),
        )
        .toList();
  }

  // PROPERTIES
  final importedItemIds = <String>[].obs;

  // GETTERS
  WindowManager get window => windowManager;

  List<ContextMenuItem> get menuItems {
    return [
      if (AppPersistence.to.sync.val) ...[
        ContextMenuItem(
          title: 'sync'.tr,
          leading: const Icon(Iconsax.cloud_change_outline),
          onSelected: SyncService.to.sync,
        ),
      ],
      // ContextMenuItem(
      //   title: 'scan'.tr,
      //   leading: const Icon(Iconsax.scan),
      //   onSelected: () {
      //     UIUtils.showSimpleDialog(
      //       'Scan Barcodes',
      //       'Coming soon...',
      //     );
      //   },
      // ),
    ];
  }

  List<ContextMenuItem> get menuItemsSort {
    final sortName = itemsController.sortOrder.value.name;
    final ascending = sortName.contains('Ascending');

    final icon = Icon(
      ascending ? LineAwesome.sort_up_solid : LineAwesome.sort_down_solid,
    );

    return [
      ContextMenuItem(
        title: 'title'.tr,
        leading: Icon(Iconsax.text_outline, size: popupIconSize),
        trailing: sortName.contains('title') ? icon : null,
        onSelected: () {
          itemsController.sortOrder.value =
              !sortName.contains('title') || ascending
                  ? LisoItemSortOrder.titleDescending
                  : LisoItemSortOrder.titleAscending;
        },
      ),
      ContextMenuItem(
        title: 'category'.tr,
        leading: Icon(Iconsax.category_outline, size: popupIconSize),
        trailing: sortName.contains('category') ? icon : null,
        onSelected: () {
          itemsController.sortOrder.value =
              !sortName.contains('category') || ascending
                  ? LisoItemSortOrder.categoryDescending
                  : LisoItemSortOrder.categoryAscending;
        },
      ),
      ContextMenuItem(
        title: 'date_modified'.tr,
        leading: Icon(Iconsax.calendar_outline, size: popupIconSize),
        trailing: sortName.contains('dateModified') ? icon : null,
        onSelected: () {
          itemsController.sortOrder.value =
              !sortName.contains('dateModified') || ascending
                  ? LisoItemSortOrder.dateModifiedDescending
                  : LisoItemSortOrder.dateModifiedAscending;
        },
      ),
      ContextMenuItem(
        title: 'date_created'.tr,
        leading: Icon(Iconsax.calendar_tick_outline, size: popupIconSize),
        trailing: sortName.contains('dateCreated') ? icon : null,
        onSelected: () {
          itemsController.sortOrder.value =
              !sortName.contains('dateCreated') || ascending
                  ? LisoItemSortOrder.dateCreatedDescending
                  : LisoItemSortOrder.dateCreatedAscending;
        },
      ),
      ContextMenuItem(
        title: 'favorite'.tr,
        leading: Icon(Iconsax.heart_outline, size: popupIconSize),
        trailing: sortName.contains('favorite') ? icon : null,
        onSelected: () {
          itemsController.sortOrder.value =
              !sortName.contains('favorite') || ascending
                  ? LisoItemSortOrder.favoriteDescending
                  : LisoItemSortOrder.favoriteAscending;
        },
      ),
      ContextMenuItem(
        title: 'protected'.tr,
        leading: Icon(Iconsax.lock_outline, size: popupIconSize),
        trailing: sortName.contains('protected') ? icon : null,
        onSelected: () {
          itemsController.sortOrder.value =
              !sortName.contains('protected') || ascending
                  ? LisoItemSortOrder.protectedDescending
                  : LisoItemSortOrder.protectedAscending;
        },
      ),
    ];
  }

  // INIT
  @override
  void onReady() {
    _initAppLifeCycleEvents();
    // init();
    super.onReady();
  }

  // FUNCTIONS

  void init() async {
    // load listview
    load();

    if (isAutofill) {
      // show all items from all vaults
      drawerController.filterGroupId.value = '';
      LisoAutofillService.to.request();
    } else {
      // incase cipher key is still empty for some reason
      // retry again after a few seconds
      if (SecretPersistence.to.cipherKey.isEmpty) {
        Future.delayed(3.seconds).then((x) {
          // sync vault
          SyncService.to.sync();
        });
      } else {
        // sync vault
        SyncService.to.sync();

        // // show upgrade screen every app open
        // if (!PurchasesService.to.isPremium) {
        //   await Future.delayed(5.seconds);
        //   Utils.adaptiveRouteOpen(name: Routes.upgrade);
        // }
      }
    }

    _updateBuildNumber();
    console.info('postInit');
  }

  void search({String query = ''}) async {
    if (Get.context == null) {
      return console.error('Get.context is null');
    }

    searchDelegate = ItemsSearchDelegate(ItemsService.to.data);

    await showSearch(
      context: Get.context!,
      delegate: searchDelegate!,
      query: query,
    );

    searchDelegate = null;
  }

  Future<void> load() async {
    ItemsController.to.load();
    GroupsController.to.load();
    CategoriesController.to.load();
    drawerController.refresh(); // update drawer state
    // reload SearchDelegate to reflect
    searchDelegate?.reload(Get.context!);
  }

  void _initAppLifeCycleEvents() {
    // auto-lock after app is inactive
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      console.warning(msg!);
      // ignore if not logged in
      if (!WalletService.to.isReady) {
        console.warning('lifecycle: wallet is not ready');
        return Future.value(msg);
      }

      if (!timeLockEnabled) {
        console.warning('lifecycle: timeLock is disabled');
        return Future.value(msg);
      }

      final timeLockDuration = persistence.timeLockDuration.val.seconds;

      // RESUMED
      if (msg == AppLifecycleState.resumed.toString()) {
        if (lastInactiveTime == null) return Future.value(msg);
        final expirationTime = lastInactiveTime!.add(timeLockDuration);

        console.wtf(
          'lifecycle: expires in ${DateFormat.yMMMMd().add_jms().format(expirationTime)}',
        );

        // expired
        if (expirationTime.isBefore(DateTime.now())) {
          console.wtf('lifecycle: expired time lock');
          Get.toNamed(Routes.unlock, parameters: {'mode': 'regular'});
        }
      }
      // INACTIVE
      else if (msg == AppLifecycleState.inactive.toString()) {
        lastInactiveTime = DateTime.now();

        console.wtf(
          'lifecycle: locking in ${timeLockDuration.inSeconds} seconds of inactivity',
        );
      }

      return Future.value(msg);
    });
  }

  void _updateBuildNumber() async {
    persistence.lastBuildNumber.val = int.parse(
      metadataApp.buildNumber,
    );
  }

  void emptyTrash() {
    void empty() async {
      Get.back();
      final items = ItemsService.to.data.where((e) => e.trashed);
      await ItemsService.to.hideleteItems(items);
      load();

      NotificationsService.to.notify(
        title: 'Trash Emptied',
        body: 'Your trash is now empty',
      );
    }

    const dialogContent = Text(
      'Are you sure you want to empty the trash?',
    );

    Get.dialog(AlertDialog(
      title: const Text('Empty Trash'),
      content: isSmallScreen
          ? dialogContent
          : const SizedBox(width: 450, child: dialogContent),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: empty,
          child: const Text('Empty Trash'),
        ),
      ],
    ));
  }

  void emptyDeleted() {
    void empty() async {
      Get.back();
      final items = ItemsService.to.data.where((e) => e.deleted);
      await ItemsService.to.deleteItems(items);
      load();

      NotificationsService.to.notify(
        title: 'Deleted Items Emptied',
        body: 'Your deleted items is now empty',
      );
    }

    const dialogContent = Text(
      'Are you sure you want to permanently empty the deleted items?',
    );

    Get.dialog(AlertDialog(
      title: const Text('Empty Deleted'),
      content: isSmallScreen
          ? dialogContent
          : const SizedBox(width: 450, child: dialogContent),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: empty,
          child: const Text('Empty Deleted'),
        ),
      ],
    ));
  }

  void showConfirmImportDialog() {
    final backupFile = File(join(
      LisoPaths.tempPath,
      'backup.$kVaultExtension',
    ));

    void confirm() {
      importedItemIds.clear();
      // delete local backup as it's no longer needed
      backupFile.delete();
      Get.back();
    }

    void undo() async {
      Get.back();

      // delete imported items permanently
      for (var e in importedItemIds) {
        AppPersistence.to.addToDeletedItems(e);
      }

      final vault = await LisoManager.parseVaultBytes(
        await backupFile.readAsBytes(),
      );

      await LisoManager.importVault(vault);
      importedItemIds.clear();
      load();

      UIUtils.showSnackBar(
        title: 'Reverted Items',
        message: 'Recently imported items were reverted.',
      );
    }

    const dialogContent = Text(
      'Please decide to keep or undo your changes.',
    );

    Get.dialog(AlertDialog(
      title: const Text('Imported Items'),
      content: isSmallScreen
          ? dialogContent
          : const SizedBox(width: 450, child: dialogContent),
      actions: [
        TextButton(
          onPressed: undo,
          child: const Text('Undo'),
        ),
        TextButton(
          onPressed: confirm,
          child: const Text('Keep'),
        ),
      ],
    ));
  }

  void showSeed() async {
    // prompt password from unlock screen
    final unlocked = await Get.toNamed(
          Routes.unlock,
          parameters: {
            'mode': 'password_prompt',
            'reason': 'Show Master Seed Phrase',
          },
        ) ??
        false;

    if (!unlocked) return;

    Utils.adaptiveRouteOpen(
      name: AppRoutes.seed,
      parameters: {'mode': 'display'},
    );
  }
}
