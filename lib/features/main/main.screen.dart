import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/connectivity/connectivity.service.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/features/general/centered_placeholder.widget.dart';
import 'package:liso/features/item/item.tile.dart';
import 'package:liso/features/menu/menu.button.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:liso/resources/resources.dart';

import '../../core/hive/models/item.hive.dart';
import '../../core/liso/liso.manager.dart';
import '../connectivity/connectivity_bar.widget.dart';
import '../drawer/drawer.widget.dart';
import '../drawer/drawer_widget.controller.dart';
import '../sync/sync.service.dart';
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

  Widget itemBuilder(context, index) => ItemTile(
        controller.data[index],
        key: GlobalKey(),
      );

  @override
  Widget? builder() {
    final listView = Obx(
      () => Opacity(
        opacity: SyncService.to.syncing ? 0.5 : 1,
        child: AbsorbPointer(
          absorbing: SyncService.to.syncing,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: controller.data.length,
            itemBuilder: itemBuilder,
            separatorBuilder: (context, index) => const Divider(height: 0),
            padding: const EdgeInsets.only(bottom: 15),
          ),
        ),
      ),
    );

    final childContent = controller.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: LineIcons.seedling,
        message: 'no_items'.tr,
        child: DrawerMenuController.to.boxFilter.value == HiveBoxFilter.all
            ? Obx(
                () => ContextMenuButton(
                  controller.menuItemsCategory,
                  enabled: !SyncService.to.syncing,
                  child: TextButton.icon(
                    icon: const Icon(LineIcons.plus),
                    label: Text(
                      'add_item'.tr,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: !SyncService.to.syncing ? () {} : null,
                  ),
                ),
              )
            : null,
      ),
    );

    final content = Column(
      children: [
        const ConnectivityBar(),
        Expanded(child: childContent),
      ],
    );

    final appBarActions = [
      Obx(
        () => IconButton(
          icon: const Icon(LineIcons.search),
          onPressed: !SyncService.to.syncing ? controller.search : null,
        ),
      ),
      Obx(
        () => ContextMenuButton(
          controller.menuItemsSort,
          enabled: !SyncService.to.syncing,
          initialItem: controller.menuItemsSort.firstWhere(
            (e) => controller.sortOrder.value.name
                .toLowerCase()
                .contains(e.title.toLowerCase().replaceAll(' ', '')),
          ),
          child: IconButton(
            icon: const Icon(LineIcons.sort),
            onPressed: !SyncService.to.syncing ? () {} : null,
          ),
        ),
      ),
      SimpleBuilder(
        builder: (_) {
          if (!PersistenceService.to.sync.val) return const SizedBox.shrink();
          final changeCount = PersistenceService.to.changes.val;

          final syncButton = IconButton(
            icon: const Icon(LineIcons.syncIcon),
            onPressed: SyncService.to.sync,
          );

          final syncBadge = Badge(
            badgeContent: Text(changeCount.toString()),
            position: BadgePosition.topEnd(top: -1, end: -5),
            child: syncButton,
          );

          const progressIndicator = Padding(
            padding: EdgeInsets.all(10),
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(),
              ),
            ),
          );

          return Obx(
            () => Visibility(
              visible:
                  !SyncService.to.syncing && ConnectivityService.to.connected(),
              child: changeCount > 0 ? syncBadge : syncButton,
              replacement:
                  SyncService.to.syncing ? progressIndicator : const SizedBox(),
            ),
          );
        },
      ),
      const SizedBox(width: 10),
    ];

    final appBarTitle = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(Images.logo, height: 17),
        const SizedBox(width: 10),
        const Text(kAppName, style: TextStyle(fontSize: 20))
      ],
    );

    final appBar = AppBar(
      centerTitle: false,
      title: appBarTitle,
      actions: appBarActions,
    );

    final floatingActionButton = Obx(
      () => ContextMenuButton(
        controller.menuItemsCategory,
        enabled: !SyncService.to.syncing,
        child: FloatingActionButton(
          child: const Icon(LineIcons.plus),
          onPressed: () {},
        ),
      ),
    );

    if (screen.isDesktop) {
      return Row(
        children: [
          const SizedBox(width: 240.0, child: DrawerMenu()),
          Container(width: 0.5, color: Colors.black),
          Expanded(
            child: Scaffold(
              key: controller.scaffoldKey,
              appBar: appBar,
              body: content,
              bottomNavigationBar: ButtonBar(
                children: [
                  TextButton.icon(
                    label: const Text('Sync'),
                    icon: const Icon(LineIcons.syncIcon),
                    onPressed: () async {
                      // const serverPath =
                      //     '/Users/nemoryoliver/Library/Containers/com.liso.app/Data/Library/Application Support/com.liso.app/temp/temp_vault.liso';
                      // final archiveResult = LisoManager.readArchive(serverPath);

                      // archiveResult.fold(
                      //   (error) => console.error('error: $error'),
                      //   (archive) async {
                      //     await LisoManager.extractArchive(
                      //       archive,
                      //       path: LisoManager.tempPath,
                      //     );
                      //   },
                      // );

                      final localItems = HiveManager.items!;
                      final cipher = HiveAesCipher(Globals.encryptionKey);
                      final tempItems = await Hive.openBox<HiveLisoItem>(
                        'temp_$kHiveBoxItems',
                        encryptionCipher: cipher,
                        path: LisoManager.tempPath,
                      );

                      if (tempItems.isEmpty) {
                        tempItems.close();
                        return console.warning('temp items is empty');
                      }

                      console.warning('server items: ${tempItems.length}');
                      console.warning('local items: ${localItems.length}');

                      // MERGED
                      final mergedItems = {
                        ...tempItems.values,
                        ...localItems.values
                      };

                      console.info('merged: ${mergedItems.length}');
                      final leastUpdatedDuplicates = <HiveLisoItem>[];

                      for (var x in mergedItems) {
                        console.warning(
                          '${x.identifier} - ${x.metadata.updatedTime}',
                        );
                        // skip if item already added to least updated item list
                        if (leastUpdatedDuplicates
                            .where((e) => e.identifier == x.identifier)
                            .isNotEmpty) continue;

                        // find duplicates
                        final duplicate = mergedItems
                            .where((y) => y.identifier == x.identifier);

                        if (duplicate.length > 1) {
                          // return the least updated item in duplicate
                          final _leastUpdatedItem = duplicate
                                  .first.metadata.updatedTime
                                  .isBefore(duplicate.last.metadata.updatedTime)
                              ? duplicate.first
                              : duplicate.last;
                          leastUpdatedDuplicates.add(_leastUpdatedItem);
                        }
                      }

                      console.info(
                          'least updated duplicates: ${leastUpdatedDuplicates.length}');
                      // remove duplicate + least updated item
                      mergedItems.removeWhere(
                        (e) => leastUpdatedDuplicates.contains(e),
                      );

                      console.info('final: ${mergedItems.length}');
                      for (var e in mergedItems) {
                        console.warning(
                          '${e.identifier} - ${e.metadata.updatedTime}',
                        );
                      }

                      // // delete temp items
                      // tempItems.deleteFromDisk();
                      // // clear and reload updated items
                      // HiveManager.items!.clear();
                      // HiveManager.items!.addAll(mergedItems);
                      // // upSync
                      // S3Service.to.upSync();
                    },
                  ),
                ],
              ),
              floatingActionButton: Obx(
                () =>
                    DrawerMenuController.to.boxFilter.value == HiveBoxFilter.all
                        ? floatingActionButton
                        : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      );
    }
    // 1 SECTION FOR PHONE DEVICES
    else {
      return Scaffold(
        key: controller.scaffoldKey,
        appBar: appBar,
        body: content,
        floatingActionButton: floatingActionButton,
        drawer: const DrawerMenu(),
      );
    }
  }
}
