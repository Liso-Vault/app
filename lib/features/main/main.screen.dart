import 'package:badges/badges.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/connectivity/connectivity.service.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/features/general/centered_placeholder.widget.dart';
import 'package:liso/features/item/item.tile.dart';
import 'package:liso/features/menu/menu.button.dart';
import 'package:liso/resources/resources.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/persistence/persistence_builder.widget.dart';
import '../connectivity/connectivity_bar.widget.dart';
import '../drawer/drawer.widget.dart';
import '../drawer/drawer_widget.controller.dart';
import '../general/remote_image.widget.dart';
import '../s3/s3.service.dart';
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
        key: GlobalKey(), // TODO: do we still need this?
      );

  @override
  Widget? builder() {
    final addItemButton = ContextMenuButton(
      controller.menuItemsCategory,
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
      () => ListView.separated(
        shrinkWrap: true,
        itemCount: controller.data.length,
        itemBuilder: itemBuilder,
        separatorBuilder: (_, index) => const Divider(height: 0),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 15),
      ),
    );

    var childContent = controller.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onEmpty: Obx(
        () => CenteredPlaceholder(
          iconData: Iconsax.document,
          message: 'no_items'.tr,
          child: S3Service.to.syncing.value ||
                  DrawerMenuController.to.filterTrashed.value
              ? null
              : addItemButton,
        ),
      ),
    );

    // enable pull to refresh if mobile
    if (GetPlatform.isMobile) {
      childContent = RefreshIndicator(
        onRefresh: controller.sync,
        child: childContent,
      );
    }

    final content = Obx(
      () => Opacity(
        opacity: S3Service.to.syncing.value ? 0.5 : 1,
        child: AbsorbPointer(
          absorbing: S3Service.to.syncing.value,
          child: Column(
            children: [
              const ConnectivityBar(),
              Expanded(child: childContent),
            ],
          ),
        ),
      ),
    );

    final appBarActions = [
      Obx(
        () => IconButton(
          icon: const Icon(Iconsax.search_normal),
          onPressed: !S3Service.to.syncing.value ? controller.search : null,
        ),
      ),
      Obx(
        () => ContextMenuButton(
          controller.menuItemsSort,
          enabled: controller.data.isNotEmpty && !S3Service.to.syncing.value,
          initialItem: controller.menuItemsSort.firstWhere(
            (e) => controller.sortOrder.value.name
                .toLowerCase()
                .contains(e.title.toLowerCase().replaceAll(' ', '')),
          ),
          child: IconButton(
            icon: const Icon(Iconsax.sort),
            onPressed: controller.data.isNotEmpty && !S3Service.to.syncing.value
                ? () {}
                : null,
          ),
        ),
      ),
      PersistenceBuilder(
        builder: (p, context) {
          if (!Persistence.to.sync.val) return const SizedBox.shrink();
          final changeCount = Persistence.to.changes.val;

          final syncButton = IconButton(
            icon: const Icon(Iconsax.cloud_change),
            onPressed: controller.sync,
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
              visible: !S3Service.to.syncing.value &&
                  ConnectivityService.to.connected(),
              replacement: S3Service.to.syncing.value
                  ? progressIndicator
                  : const SizedBox(),
              child: changeCount > 0 ? syncBadge : syncButton,
            ),
          );
        },
      ),
      const SizedBox(width: 10),
    ];

    final appBarTitle = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RemoteImage(
          url: ConfigService.to.general.app.image,
          height: 20,
          placeholder: Image.asset(Images.logo, height: 20),
        ),
        const SizedBox(width: 10),
        Text(ConfigService.to.appName, style: const TextStyle(fontSize: 20)),
      ],
    );

    final appBar = AppBar(
      centerTitle: false,
      title: appBarTitle,
      actions: appBarActions,
    );

    // TODO: show only if there are trash items
    final clearTrashFab = FloatingActionButton(
      onPressed: controller.emptyTrash,
      child: const Icon(Iconsax.trash),
    );

    final floatingActionButton = Obx(
      () {
        if (S3Service.to.syncing.value) return const SizedBox.shrink();

        if (DrawerMenuController.to.filterTrashed.value) {
          if (DrawerMenuController.to.trashedCount > 0) {
            return clearTrashFab;
          } else {
            return const SizedBox.shrink();
          }
        }

        return ContextMenuButton(
          controller.menuItemsCategory,
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
              floatingActionButton: floatingActionButton,
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: appBar,
        body: content,
        drawer: const DrawerMenu(),
        floatingActionButton: floatingActionButton,
      );
    }
  }
}
