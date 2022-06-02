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
import '../general/custom_chip.widget.dart';
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

  Widget itemBuilder(context, index) {
    return ItemTile(
      controller.data[index],
    );
  }

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
          child: DrawerMenuController.to.filterTrashed.value
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

    final filters = Wrap(
      runSpacing: 3,
      children: [
        const Text(
          'Filters: ',
          style: TextStyle(fontSize: 9, color: Colors.grey),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.briefcase, size: 10),
            label: Text(
              DrawerMenuController.to.filterGroupLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.share, size: 10),
            label: Text(
              DrawerMenuController.to.filterSharedVaultLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.filter, size: 10),
            label: Text(
              DrawerMenuController.to.filterToggleLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.category, size: 10),
            label: Text(
              DrawerMenuController.to.filterCategoryLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
        Obx(
          () => CustomChip(
            icon: const Icon(Iconsax.tag, size: 10),
            label: Text(
              DrawerMenuController.to.filterTagLabel,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
      ],
    );

    final content = Column(
      children: [
        const ConnectivityBar(),
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
      ContextMenuButton(
        controller.menuItemsSort,
        initialItem: controller.menuItemsSort.firstWhere(
          (e) => controller.sortOrder.value.name
              .toLowerCase()
              .contains(e.title.toLowerCase().replaceAll(' ', '')),
        ),
        child: IconButton(
          icon: const Icon(Iconsax.sort),
          onPressed: () {},
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
        Text(
          ConfigService.to.appName,
          style: const TextStyle(fontSize: 20),
        ),
        if (isBeta) ...[
          const Text(
            ' Beta',
            style: TextStyle(fontSize: 12, color: Colors.cyan),
          ),
        ]
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

    final fab = Obx(
      () {
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
              floatingActionButton: fab,
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: appBar,
        body: SafeArea(child: content),
        drawer: const DrawerMenu(),
        floatingActionButton: fab,
      );
    }
  }
}
