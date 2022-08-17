import 'package:badges/badges.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/general/centered_placeholder.widget.dart';
import 'package:liso/features/items/item.tile.dart';
import 'package:liso/features/items/items.controller.dart';
import 'package:liso/features/joined_vaults/joined_vault.controller.dart';
import 'package:liso/features/menu/menu.button.dart';

import '../../core/hive/models/group.hive.dart';
import '../../core/persistence/persistence_builder.widget.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../connectivity/connectivity_bar.widget.dart';
import '../drawer/drawer.widget.dart';
import '../drawer/drawer_widget.controller.dart';
import '../general/custom_chip.widget.dart';
import '../general/remote_image.widget.dart';
import '../groups/groups.controller.dart';
import '../joined_vaults/explorer/vault_explorer_screen.controller.dart';
import '../pro/pro.controller.dart';
import '../s3/s3.service.dart';
import '../shared_vaults/model/shared_vault.model.dart';
import '../shared_vaults/shared_vault.controller.dart';
import 'main_screen.controller.dart';

// ignore: use_key_in_widget_constructors
class MainScreen extends GetResponsiveView<MainScreenController>
    with ConsoleMixin {
  MainScreen({Key? key})
      : super(
          key: key,
          settings: const ResponsiveScreenSettings(
            desktopChangePoint: kDesktopChangePoint,
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
      padding: EdgeInsets.zero,
      child: TextButton.icon(
        icon: const Icon(Iconsax.add_circle),
        onPressed: () {},
        label: Text(
          'add_item'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );

    final listView = Obx(
      () => ListView.builder(
        shrinkWrap: true,
        itemCount: itemsController.data.length,
        itemBuilder: (_, index) => ItemTile(itemsController.data[index]),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 15),
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
          OutlinedButton(
            onPressed: () => Utils.adaptiveRouteOpen(
              name: Routes.upgrade,
              parameters: {
                'title': 'Password Health',
                'body':
                    'Monitor the health of your passwords. Upgrade to Pro to take advantage of this powerful feature.',
              },
            ),
            child: const Text('Upgrade To Identify'),
          ),
        ],
      ),
    );

    var childContent = itemsController.obx(
      (_) => !ProController.to.limits.passwordHealth &&
              drawerController.filterPasswordHealth.value
          ? weakPasswords
          : listView,
      // onLoading: const BusyIndicator(),
      onEmpty: drawerController.filterPasswordHealth.value
          ? const CenteredPlaceholder(
              iconData: LineIcons.check,
              message: 'No Fragile Passwords Detected',
            )
          : Obx(
              () => CenteredPlaceholder(
                iconData: Iconsax.document,
                message: 'no_items'.tr,
                child:
                    drawerController.filterTrashed.value ? null : addItemButton,
              ),
            ),
    );

    // enable pull to refresh if mobile
    if (GetPlatform.isMobile) {
      childContent = RefreshIndicator(
        onRefresh: S3Service.to.sync,
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
            icon: const Icon(Iconsax.briefcase, size: 10),
            label: Text(
              drawerController.filterGroupLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.share, size: 10),
            label: Text(
              drawerController.filterSharedVaultLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.filter, size: 10),
            label: Text(
              drawerController.filterToggleLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.category, size: 10),
            label: Text(
              drawerController.filterCategoryLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.tag, size: 10),
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
            visible: S3Service.to.syncing.value,
            child: const LinearProgressIndicator(),
          ),
        ),
        const ConnectivityBar(),
        PersistenceBuilder(
          builder: (p, context) => Visibility(
            visible: !p.backedUpSeed.val,
            child: Card(
              elevation: 1.0,
              child: ListTile(
                iconColor: kAppColor,
                // dense: Utils.isDrawerExpandable,
                contentPadding: const EdgeInsets.all(10),
                selectedTileColor: themeColor.withOpacity(0.05),
                // TODO: localize
                title: const Text(
                  "Backup Your Seed Phrase",
                  style: TextStyle(color: kAppColor),
                ),
                subtitle: const Text(
                  "This is the only key to access and decrypt your vault",
                ),
                leading: const Icon(Iconsax.key),
                trailing: OutlinedButton(
                  onPressed: controller.showSeed,
                  child: const Text('Backup'),
                ),
              ),
            ),
          ),
        ),
        Expanded(child: childContent),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: filters,
          ),
        ),
      ],
    );

    final appBarActions = [
      IconButton(
        icon: const Icon(Iconsax.search_normal),
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
          child: const Icon(Iconsax.sort),
        ),
      ),
      if (!Globals.isAutofill) ...[
        PersistenceBuilder(
          builder: (p, context) => Badge(
            showBadge: p.sync.val && p.changes.val > 0,
            badgeContent: Text(p.changes.val.toString()),
            position: BadgePosition.topEnd(top: -1, end: -5),
            child: IconButton(
              onPressed: S3Service.to.sync,
              icon: const Icon(Iconsax.cloud_change),
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
              onTap: () => drawerController.filterByGroupId(group.id),
              child: Row(
                children: [
                  Icon(
                    Iconsax.briefcase,
                    color: isSelected ? themeColor : null,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      group.reservedName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: isSelected ? themeColor : null),
                    ),
                  ),
                  Chip(label: Text(count.toString())),
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
                onTap: () =>
                    drawerController.filterBySharedVaultId(vault.docId),
                child: Row(
                  children: [
                    vault.iconUrl.isEmpty
                        ? Icon(
                            Iconsax.share,
                            color: isSelected ? themeColor : null,
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
                    Chip(label: Text(count.toString())),
                  ],
                ),
              );
            },
          ).toList();

          final joinedGroups = JoinedVaultsController.to.data.map(
            (vault) {
              return PopupMenuItem<SharedVault>(
                onTap: () async {
                  await Future.delayed(const Duration(milliseconds: 10));
                  VaultExplorerScreenController.vault = vault;
                  Utils.adaptiveRouteOpen(name: Routes.vaultExplorer);
                },
                child: Row(
                  children: [
                    vault.iconUrl.isEmpty
                        ? const Icon(LineIcons.briefcase)
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
                onTap: () => drawerController.filterByGroupId(''),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.briefcase,
                      color: isAllSelected ? themeColor : null,
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
                    Chip(label: Text(allCount.toString())),
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
                  Text(
                    drawerController.filterGroupLabel,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(LineIcons.caretDown, size: 15),
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
      automaticallyImplyLeading: !Globals.isAutofill,
      actions: appBarActions,
      leading: Globals.isAutofill
          ? null
          : IconButton(
              onPressed: () => scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(Icons.menu),
            ),
    );

    // TODO: show only if there are trash items
    final clearTrashFab = FloatingActionButton(
      onPressed: controller.emptyTrash,
      child: const Icon(Iconsax.trash),
    );

    final fab = Globals.isAutofill
        ? null
        : Obx(
            () {
              if (drawerController.filterTrashed.value) {
                if (drawerController.trashedCount > 0) {
                  return clearTrashFab;
                } else {
                  return const SizedBox.shrink();
                }
              }

              return ContextMenuButton(
                controller.menuItemsCategory,
                sheetForSmallScreen: true,
                child: FloatingActionButton(
                  child: const Icon(LineIcons.plus),
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
