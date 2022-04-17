import 'dart:async';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/form_fields/password.field.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/hive/models/item.hive.dart';
import 'package:liso/core/notifications/notifications.manager.dart';
import 'package:liso/core/services/authentication.service.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/about/about_screen.controller.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/export/export_screen.controller.dart';
import 'package:liso/features/ipfs/ipfs_screen.controller.dart';
import 'package:liso/features/reset/reset_screen.controller.dart';
import 'package:liso/features/settings/settings_screen.controller.dart';

import '../../core/form_fields/pin.field.dart';
import '../../core/liso/liso.manager.dart';
import '../../core/utils/utils.dart';
import '../drawer/drawer_widget.controller.dart';
import '../ipfs/explorer/ipfs_exporer_screen.controller.dart';
import '../item/item_screen.controller.dart';
import '../menu/menu.item.dart';
import '../s3/explorer/s3_exporer_screen.controller.dart';
import '../s3/s3.service.dart';
import '../search/search.delegate.dart';

class MainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainScreenController());
    Get.lazyPut(() => DrawerMenuController());
    // WIDGETS
    Get.create(() => PasswordFormFieldController());
    Get.create(() => PINFormFieldController());
    // SCREENS
    Get.create(() => ItemScreenController());
    Get.create(() => SettingsScreenController());
    Get.create(() => AboutScreenController());
    Get.create(() => ExportScreenController());
    Get.create(() => ResetScreenController());
    // ipfs
    Get.create(() => IPFSScreenController());
    Get.create(() => IPFSExplorerScreenController());
    // S3
    Get.create(() => S3ExplorerScreenController());
  }
}

class MainScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static MainScreenController get to => Get.find();

  // VARIABLES
  Timer? timer;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final sortOrder = LisoItemSortOrder.dateModifiedDescending.obs;
  final drawerController = Get.find<DrawerMenuController>();
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
              console.warning('context tapped');
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
  StreamSubscription? itemsSubscription,
      archivedSubscription,
      trashSubscription;

  // PROPERTIES
  final data = <HiveLisoItem>[].obs;

  // GETTERS
  bool get expandableDrawer =>
      scaffoldKey.currentState?.hasDrawer ?? GetPlatform.isMobile;

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
    downSync();
    _initAppLifeCycleEvents();
    Utils.setDisplayMode();
    _load();
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

  void _watchBoxes() async {
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

    itemsSubscription = HiveManager.items?.watch().listen(_onChangesDetected);
    archivedSubscription =
        HiveManager.archived?.watch().listen(_onChangesDetected);
    trashSubscription = HiveManager.trash?.watch().listen(_onChangesDetected);
  }

  void unwatchBoxes() {
    itemsSubscription?.cancel();
    archivedSubscription?.cancel();
    trashSubscription?.cancel();
  }

  void _onChangesDetected(BoxEvent event) async {
    console.info('hive changes detected');
    _load();
    persistence.changes.val++;
    // await IPFSService.to.updateLocalMetadata();

    // // if sync and instant sync is on
    // if (persistence.ipfsSync.val && persistence.ipfsInstantSync.val) {
    //   IPFSService.to.sync();
    // }
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

  void _initAppLifeCycleEvents() {
    // // if sync and instant sync is on
    // if (persistence.ipfsSync.val && persistence.ipfsInstantSync.val) {
    //   IPFSService.to.sync();
    // }

    // auto-lock after app is inactive
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      console.warning(msg!);

      if (msg == AppLifecycleState.resumed.toString()) {
        timer?.cancel();

        if (AuthenticationService.to.isAuthenticated &&
            Globals.encryptionKey == null) {
          Get.toNamed(Routes.unlock);
        }
      } else if (msg == AppLifecycleState.inactive.toString()) {
        // lock after <duration> of inactivity
        if (Globals.timeLockEnabled) {
          final timeLock = persistence.timeLockDuration.val.seconds;
          timer = Timer.periodic(timeLock, (timer) {
            Globals.encryptionKey = null;
            timer.cancel();
          });
        }
      }

      return Future.value(msg);
    });
  }

  Future<void> downSync() async {
    downSyncing.value = true;
    await S3Service.to.downSync();
    downSyncing.value = false;
    reload();
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

  bool oliver = true;

  void test() async {
    console.error(oliver ? 'oliver' : 'anna');

    const path =
        '/Users/nemoryoliver/Library/Containers/com.liso.app/Data/Library/Application Support/com.liso.app/';

    final readResult = LisoManager.readArchive(
      path + (oliver ? 'oliver.liso' : 'anna.liso'),
    );

    Archive? archive;

    readResult.fold(
      (error) => console.error('error: $error'),
      (response) => archive = response,
    );

    await HiveManager.closeBoxes();

    await LisoManager.extractArchive(
      archive!,
      path: LisoManager.hivePath,
    );

    await HiveManager.openBoxes();

    reload();

    oliver = !oliver;
  }
}
