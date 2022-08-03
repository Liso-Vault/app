import 'dart:async';
import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/categories/categories.controller.dart';
import 'package:liso/features/items/items.controller.dart';
import 'package:liso/features/items/items.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/firebase/auth.service.dart';
import '../../core/hive/models/app_domain.hive.dart';
import '../../core/services/alchemy.service.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/utils.dart';
import '../drawer/drawer_widget.controller.dart';
import '../groups/groups.controller.dart';
import '../menu/menu.item.dart';
import '../s3/s3.service.dart';
import '../search/search.delegate.dart';

class MainScreenController extends GetxController
    with ConsoleMixin, WindowListener {
  static MainScreenController get to => Get.find();

  // VARIABLES
  Timer? timeLockTimer;
  ItemsSearchDelegate? searchDelegate;
  AutofillPreferences? pref;
  AutofillMetadata? metadata;
  AutofillServiceStatus? status;

  final autofill = AutofillService();
  final persistence = Get.find<Persistence>();
  final itemsController = Get.find<ItemsController>();
  final drawerController = Get.find<DrawerMenuController>();

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

  // GETTERS
  List<ContextMenuItem> get menuItems {
    return [
      if (persistence.sync.val) ...[
        ContextMenuItem(
          title: 'sync'.tr,
          leading: const Icon(Iconsax.cloud_change),
          onSelected: S3Service.to.sync,
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
      ascending ? LineIcons.sortUpAscending : LineIcons.sortDownDescending,
    );

    return [
      ContextMenuItem(
        title: 'title'.tr,
        leading: const Icon(Iconsax.text),
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
        leading: const Icon(Iconsax.category),
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
        leading: const Icon(Iconsax.calendar),
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
        leading: const Icon(Iconsax.calendar_tick),
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
        leading: const Icon(Iconsax.heart),
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
        leading: const Icon(Iconsax.lock),
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
  void onInit() async {
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

  void postInit() {
    // firebase auth
    AuthService.to.signIn();
    // load listview
    load();

    if (!Globals.isAutofill) {
      // load balances
      AlchemyService.to.init();
      AlchemyService.to.load();
      // sync vault
      S3Service.to.sync();
    } else {
      // show all items from all vaults
      drawerController.filterGroupId.value = '';
      _autofillAction();

      if (!WalletService.to.isReady) {
        // TODO: show some message a vault is needed
      }
    }

    _updateBuildNumber();
  }

  void _autofillAction() async {
    if (!Globals.isAutofill) return;
    await _updateAutofillStats();

    // SAVE MODE
    if (metadata?.saveInfo != null) {
      _saveAutofill();
    }
    // FILL MODE
    else {
      String query = '';

      if (metadata!.webDomains.isNotEmpty) {
        query = metadata!.webDomains.first.domain;
      } else {
        query = metadata!.packageNames.first;
      }

      final appDomains = ConfigService.to.appDomains.data.where((e) {
        // DOMAINS
        if (metadata?.webDomains != null &&
            e.domains
                .where((d) => metadata!.webDomains.contains(AutofillWebDomain(
                      domain: d.domain,
                      scheme: d.scheme,
                    )))
                .isNotEmpty) {
          return true;
        }

        // PACKAGE NAMES
        if (metadata?.packageNames != null &&
            e.appIds
                .where((a) => metadata!.packageNames.contains(a))
                .isNotEmpty) {
          return true;
        }

        return false;
      }).toList();

      search(query: appDomains.isNotEmpty ? appDomains.first.title : query);
    }
  }

  void _saveAutofill() {
    if (metadata!.webDomains.isEmpty && metadata!.packageNames.isEmpty) {
      return console.error('invalid autofill metadata');
    }

    final appDomains = ConfigService.to.appDomains.data.where((e) {
      // DOMAINS
      if (metadata?.webDomains != null &&
          e.domains
              .where((d) => metadata!.webDomains.contains(AutofillWebDomain(
                    domain: d.domain,
                    scheme: d.scheme,
                  )))
              .isNotEmpty) {
        return true;
      }

      // PACKAGE NAMES
      if (metadata?.packageNames != null &&
          e.appIds
              .where((a) => metadata!.packageNames.contains(a))
              .isNotEmpty) {
        return true;
      }

      return false;
    }).toList();

    final appIds = metadata?.packageNames != null
        ? metadata!.packageNames.toList()
        : <String>[];

    final domains = metadata?.webDomains != null
        ? metadata!.webDomains
            .toList()
            .map((e) => HiveDomain(scheme: e.scheme, domain: e.domain))
            .toList()
        : <HiveDomain>[];

    String service = '';

    if (metadata!.packageNames.isNotEmpty) {
      service = metadata!.packageNames.first;
    } else if (metadata!.webDomains.isNotEmpty) {
      service = metadata!.webDomains.first.domain;
    }

    final appDomain = appDomains.isNotEmpty
        ? appDomains.first
        : HiveAppDomain(
            title: service,
            appIds: appIds,
            domains: domains,
            iconUrl: '',
          );

    console.info('app domain: ${appDomain.toJson()}');

    final username = metadata?.saveInfo?.username ?? '';
    final password = metadata?.saveInfo?.password ?? '';

    Utils.adaptiveRouteOpen(
      name: Routes.item,
      parameters: {
        'mode': 'saved_autofill',
        'category': LisoItemCategory.login.name,
        'title': '$username ${appDomain.title}',
        'username': username,
        'password': password,
        'app_domain': jsonEncode(appDomain.toJson()),
      },
    );
  }

  Future<void> _updateAutofillStats() async {
    pref = await autofill.getPreferences();
    metadata = await autofill.getAutofillMetadata();
    status = await autofill.status();

    console.warning(''''
fillRequestedAutomatic: ${await autofill.fillRequestedAutomatic}'
fillRequestedInteractive: ${await autofill.fillRequestedInteractive}'
hasAutofillServicesSupport: ${await autofill.hasAutofillServicesSupport}'
hasEnabledAutofillServices: ${await autofill.hasEnabledAutofillServices}'
  
// METADATA
saveInfo: ${metadata?.saveInfo?.toJson()}'
packageNames: ${metadata?.packageNames}'
webDomains: ${metadata?.webDomains}'

// PREFERENCE
enableDebug: ${pref?.enableDebug}'
enableSaving: ${pref?.enableSaving}'

// STATUS
status: ${status.toString()}'
    ''');
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

      if (msg == AppLifecycleState.resumed.toString()) {
        timeLockTimer?.cancel();

        if (WalletService.to.isSaved && !WalletService.to.isReady) {
          Get.toNamed(
            Routes.unlock,
            parameters: {'mode': 'regular'},
          );
        }
      } else if (msg == AppLifecycleState.inactive.toString()) {
        // lock after <duration> of inactivity
        if (Globals.timeLockEnabled) {
          final timeLock = persistence.timeLockDuration.val.seconds;
          timeLockTimer = Timer.periodic(timeLock, (timer) async {
            Get.toNamed(
              Routes.unlock,
              parameters: {'mode': 'regular'},
            );

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
