import 'package:app_core/config.dart';
import 'package:app_core/connectivity/connectivity.service.dart';
import 'package:app_core/connectivity/connectivity_bar.widget.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/persistence/persistence_builder.widget.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/premium_card.widget.dart';
import 'package:app_core/widgets/remote_image.widget.dart';
import 'package:badges/badges.dart' as badges;
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/items/item.tile.dart';
import 'package:liso/features/items/items.controller.dart';
import 'package:liso/features/joined_vaults/joined_vault.controller.dart';
import 'package:liso/features/menu/menu.button.dart';

import '../../core/hive/models/group.hive.dart';
import '../app/routes.dart';
import '../drawer/drawer.widget.dart';
import '../drawer/drawer_widget.controller.dart';
import '../files/sync.service.dart';
import '../general/centered_placeholder.widget.dart';
import '../general/custom_chip.widget.dart';
import '../groups/groups.controller.dart';
import '../joined_vaults/explorer/vault_explorer_screen.controller.dart';
import '../shared_vaults/model/shared_vault.model.dart';
import '../shared_vaults/shared_vault.controller.dart';
import 'main_screen.controller.dart';

// ignore: use_key_in_widget_constructors
class MainScreen extends GetResponsiveView<MainScreenController>
    with ConsoleMixin {
  MainScreen({Key? key})
      : super(
          key: key,
          settings: ResponsiveScreenSettings(
            desktopChangePoint: CoreConfig().desktopChangePoint,
          ),
        );

  @override
  Widget? builder() {
    var scaffoldKey = GlobalKey<ScaffoldState>();
    final itemsController = Get.find<ItemsController>();
    final drawerController = Get.find<DrawerMenuController>();

    final addItemButton = ContextMenuButton(
      controller.menuItemsCategory,
      sheetForSmallScreen: true,
      gridForLargeScreen: true,
      padding: EdgeInsets.zero,
      child: OutlinedButton.icon(
        icon: const Icon(Iconsax.add_circle_outline),
        onPressed: () {},
        label: Text(
          'add_item'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );

    final listView = Obx(
      () => ListView.separated(
        separatorBuilder: (context, index) => Divider(
          height: 0,
          color: Colors.grey.withOpacity(0.1),
        ),
        shrinkWrap: true,
        itemCount: itemsController.data.length,
        itemBuilder: (_, index) => ItemTile(itemsController.data[index]),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 20),
      ),
    );

    final weakPasswords = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => Text(
              '${ItemsController.to.data.length}',
              style: const TextStyle(
                fontSize: 50,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text(
            'Fragile Passwords Detected',
            style: TextStyle(color: Colors.orange, fontSize: 16),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Iconsax.search_status_outline),
            label: const Text('Identify'),
            onPressed: () => Utils.adaptiveRouteOpen(
              name: Routes.upgrade,
              parameters: {
                'title': 'Password Health',
                'body':
                    'Monitor the health of your passwords. Upgrade to Pro to take advantage of this powerful feature.',
              },
            ),
          ),
        ],
      ),
    );

    var childContent = itemsController.obx(
      (_) =>
          !limits.passwordHealth && drawerController.filterPasswordHealth.value
              ? weakPasswords
              : listView,
      onEmpty: drawerController.filterPasswordHealth.value
          ? const CenteredPlaceholder(
              iconData: Icons.check,
              message: 'No Fragile Passwords Detected',
            )
          : Obx(
              () => CenteredPlaceholder(
                iconData: Iconsax.document_outline,
                message: 'no_items'.tr,
                child:
                    drawerController.filterTrashed.value ? null : addItemButton,
              ),
            ),
    );

    // enable pull to refresh if mobile
    if (GetPlatform.isMobile) {
      childContent = RefreshIndicator(
        onRefresh: SyncService.to.sync,
        child: childContent,
      );
    }

    // filters indicator in the bottom
    final filters = Wrap(
      runSpacing: 3,
      spacing: 3,
      children: [
        const Text(
          'Filters: ',
          style: TextStyle(fontSize: 9, color: Colors.grey),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.briefcase_outline, size: 10),
            label: Text(
              drawerController.filterGroupLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.share_outline, size: 10),
            label: Text(
              drawerController.filterSharedVaultLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.filter_outline, size: 10),
            label: Text(
              drawerController.filterToggleLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.category_outline, size: 10),
            label: Text(
              drawerController.filterCategoryLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.tag_outline, size: 10),
            label: Text(
              drawerController.filterTagLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
      ],
    );

    final content = Column(
      children: [
        Obx(
          () => Visibility(
            visible: SyncService.to.syncing.value,
            child: const LinearProgressIndicator(),
          ),
        ),
        const ConnectivityBar(),
        PersistenceBuilder(
          builder: (p, context) => Column(
            children: [
              Visibility(
                visible: !AppPersistence.to.backedUpSeed.val,
                child: Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.only(
                    top: 5,
                    bottom: 5,
                    left: 15,
                    right: 15,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    selectedTileColor: themeColor.withOpacity(0.05),
                    // TODO: localize
                    title: const Text(
                      "Backup Your Seed Phrase",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      "This is the only key to access and decrypt your vault",
                    ),
                    // leading: const Icon(Iconsax.key),
                    trailing: OutlinedButton(
                      onPressed: controller.showSeed,
                      child: const Text('Backup'),
                    ),
                  ),
                ),
              ),
              Obx(
                () => Visibility(
                  visible: controller.importedItemIds.isNotEmpty,
                  child: Card(
                    elevation: 2.0,
                    margin: const EdgeInsets.only(
                      top: 5,
                      bottom: 5,
                      left: 15,
                      right: 15,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      selectedTileColor: themeColor.withOpacity(0.05),
                      // TODO: localize
                      title: const Text("Recently Imported Items"),
                      subtitle: const Text(
                        "Are you satisfied with the recent import? If not, you can undo your changes.",
                      ),
                      // leading: const Icon(Iconsax.key),
                      trailing: OutlinedButton(
                        onPressed: controller.showConfirmImportDialog,
                        child: const Text('Decide'),
                      ),
                    ),
                  ),
                ),
              ),
              // Visibility(
              //   visible: AppPersistence.to.rateCardVisibility.val &&
              //       p.sessionCount.val > 15 &&
              //       isRateReviewSupported,
              //   child: Card(
              //     elevation: 2.0,
              //     margin: const EdgeInsets.only(
              //       top: 5,
              //       bottom: 5,
              //       left: 15,
              //       right: 15,
              //     ),
              //     child: ListTile(
              //       contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              //       selectedTileColor: themeColor.withOpacity(0.05),
              //       // TODO: localize
              //       title: Text(
              //           "Rate & review ${appConfig.name} on ${GetPlatform.isIOS || GetPlatform.isMacOS ? 'the App Store' : 'Google Play'}"),
              //       subtitle: Text(
              //         "Help spread awareness on why people should consider using ${appConfig.name} as their secure vault.",
              //       ),
              //       // leading: const Icon(Iconsax.key),
              //       trailing: OutlinedButton(
              //         onPressed: () {
              //           UIUtils.requestReview();
              //           AppPersistence.to.rateCardVisibility.val = false;
              //         },
              //         child: const Text('Rate'),
              //       ),
              //     ),
              //   ),
              // ),
              // show only when seed is already backed up to not overcrowd
              // Obx(
              //   () => Visibility(
              //     visible: LisoAutofillService.to.supported.value &&
              //         !LisoAutofillService.to.enabled.value &&
              //         p.backedUpSeed.val,
              //     child: Card(
              //       elevation: 2.0,
              //       margin: const EdgeInsets.only(
              //         top: 5,
              //         bottom: 5,
              //         left: 15,
              //         right: 15,
              //       ),
              //       child: ListTile(
              //         contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              //         selectedTileColor: themeColor.withOpacity(0.05),
              //         // TODO: localize
              //         title: Text(
              //             "Enable ${appConfig.name} Autofill Service"),
              //         subtitle: Text(
              //           "Automatically fill and save forms with ${appConfig.name} Autofill Service",
              //         ),
              //         // leading: const Icon(Iconsax.key),
              //         trailing: OutlinedButton(
              //           onPressed: LisoAutofillService.to.set,
              //           child: const Text('Enable'),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        Expanded(child: childContent),
        if (DrawerMenuController.to.) ... [
          const PremiumCard(),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10),
            child: filters,
          ),
        ),
      ],
    );

    final appBarActions = [
      IconButton(
        icon: const Icon(Iconsax.search_normal_outline),
        onPressed: controller.search,
      ),
      Obx(
        () => ContextMenuButton(
          controller.menuItemsSort,
          initialItem: controller.menuItemsSort.firstWhere(
            (e) => ItemsController.to.sortOrder.value.name
                .toLowerCase()
                .contains(e.title.toLowerCase().replaceAll(' ', '')),
          ),
          child: const Icon(Iconsax.sort_outline),
        ),
      ),
      if (!isAutofill) ...[
        PersistenceBuilder(
          builder: (p, context) => Visibility(
            visible: AppPersistence.to.sync.val,
            child: badges.Badge(
              showBadge: AppPersistence.to.sync.val &&
                  AppPersistence.to.changes.val > 0,
              badgeContent: Text(AppPersistence.to.changes.val.toString()),
              position: badges.BadgePosition.topEnd(top: -1, end: -5),
              child: Obx(
                () => IconButton(
                  icon: const Icon(Iconsax.cloud_change_outline),
                  onPressed: SyncService.to.syncing.value
                      ? null
                      : () {
                          if (!ConnectivityService.to.connected.value) {
                            UIUtils.showSimpleDialog(
                              'No Internet Connection',
                              'Please check your internet connection and try again',
                            );
                          }

                          SyncService.to.sync();
                        },
                ),
              ),
            ),
          ),
        ),
      ],
      const SizedBox(width: 10),
    ];

    final appBarTitle = Transform.translate(
      offset: const Offset(-12, 0),
      child: Obx(
        () {
          final groups = GroupsController.to.combined.map((group) {
            final count = ItemsController.to.raw
                .where((item) =>
                    item.groupId == group.id && !item.deleted && !item.trashed)
                .length;

            final isSelected = group.id == drawerController.filterGroupId.value;

            return PopupMenuItem<HiveLisoGroup>(
              height: popupItemHeight,
              onTap: () => drawerController.filterByGroupId(group.id),
              child: Row(
                children: [
                  Icon(
                    Iconsax.briefcase_outline,
                    color: isSelected ? themeColor : null,
                    size: popupIconSize,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      group.reservedName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: isSelected ? themeColor : null),
                    ),
                  ),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      color: Get.theme.primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList();

          final sharedGroups = SharedVaultsController.to.data.map(
            (vault) {
              final count = drawerController.groupedItems
                  .where((item) => item.sharedVaultIds.contains(vault.docId))
                  .length;

              final isSelected =
                  vault.docId == drawerController.filterSharedVaultId.value;

              return PopupMenuItem<SharedVault>(
                height: popupItemHeight,
                onTap: () =>
                    drawerController.filterBySharedVaultId(vault.docId),
                child: Row(
                  children: [
                    vault.iconUrl.isEmpty
                        ? Icon(
                            Iconsax.share_outline,
                            color: isSelected ? themeColor : null,
                            size: popupIconSize,
                          )
                        : RemoteImage(
                            url: vault.iconUrl,
                            width: 35,
                            alignment: Alignment.centerLeft,
                          ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        vault.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: isSelected ? themeColor : null),
                      ),
                    ),
                    Text(
                      count.toString(),
                      style: TextStyle(
                        color: Get.theme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ).toList();

          final joinedGroups = JoinedVaultsController.to.data.map(
            (vault) {
              return PopupMenuItem<SharedVault>(
                height: popupItemHeight,
                onTap: () async {
                  await Future.delayed(const Duration(milliseconds: 10));
                  VaultExplorerScreenController.vault = vault;
                  Utils.adaptiveRouteOpen(name: AppRoutes.vaultExplorer);
                },
                child: Row(
                  children: [
                    vault.iconUrl.isEmpty
                        ? Icon(LineAwesome.briefcase_solid, size: popupIconSize)
                        : RemoteImage(
                            url: vault.iconUrl,
                            width: 35,
                            alignment: Alignment.centerLeft,
                          ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        vault.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Chip(label: Text(count.toString())),
                  ],
                ),
              );
            },
          ).toList();

          final isAllSelected = drawerController.filterGroupId.value == '';
          final allCount = ItemsController.to.raw
              .where((e) => !e.trashed && !e.deleted)
              .length;

          return PopupMenuButton<dynamic>(
            itemBuilder: (_) => [
              PopupMenuItem<HiveLisoGroup>(
                height: popupItemHeight,
                onTap: () => drawerController.filterByGroupId(''),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.briefcase_outline,
                      color: isAllSelected ? themeColor : null,
                      size: popupIconSize,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'all'.tr,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(color: isAllSelected ? themeColor : null),
                      ),
                    ),
                    Text(
                      allCount.toString(),
                      style: TextStyle(
                        color: Get.theme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ...groups,
              if (sharedGroups.isNotEmpty) ...[
                const PopupMenuDivider(),
                ...sharedGroups,
              ],
              if (joinedGroups.isNotEmpty) ...[
                const PopupMenuDivider(),
                ...joinedGroups,
              ]
            ],
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: isSmallScreen ? 1 : 0,
                    child: Text(
                      drawerController.filterGroupLabel,
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(LineAwesome.caret_down_solid, size: 15),
                ],
              ),
            ),
          );
        },
      ),
    );

    final appBar = AppBar(
      centerTitle: false,
      title: appBarTitle,
      automaticallyImplyLeading: !isAutofill,
      actions: appBarActions,
      leading: isAutofill || !isSmallScreen
          ? null
          : IconButton(
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(Icons.menu),
            ),
    );

    // TODO: show only if there are trash items

    final fab = isAutofill
        ? null
        : Obx(
            () {
              if (drawerController.filterTrashed.value ||
                  drawerController.filterDeleted.value) {
                if (drawerController.trashedCount > 0) {
                  return FloatingActionButton(
                    onPressed: controller.emptyTrash,
                    child: const Icon(Iconsax.trash_outline),
                  );
                } else if (drawerController.deletedCount > 0) {
                  return FloatingActionButton(
                    onPressed: controller.emptyDeleted,
                    child: const Icon(Iconsax.trash_outline),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }

              return ContextMenuButton(
                controller.menuItemsCategory,
                sheetForSmallScreen: true,
                gridForLargeScreen: true,
                child: FloatingActionButton(
                  child: const Icon(LineAwesome.plus_solid),
                  onPressed: () {},
                ),
              );
            },
          );

    if (screen.isDesktop) {
      return Row(
        children: [
          const SizedBox(width: 280.0, child: DrawerMenu()),
          Container(width: 0.5, color: Colors.black),
          Expanded(
            child: Scaffold(
              appBar: appBar,
              body: content,
              floatingActionButton: fab,
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        key: scaffoldKey,
        appBar: appBar,
        body: SafeArea(child: content),
        drawer: const DrawerMenu(),
        floatingActionButton: fab,
      );
    }
  }
}
