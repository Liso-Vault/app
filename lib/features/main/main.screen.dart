import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/features/general/centered_placeholder.widget.dart';
import 'package:liso/features/item/item.tile.dart';
import 'package:liso/features/menu/menu.button.dart';
import 'package:liso/resources/resources.dart';

import '../drawer/drawer.widget.dart';
import '../drawer/drawer_widget.controller.dart';
import '../search/search.delegate.dart';
import 'main_screen.controller.dart';

// ignore: use_key_in_widget_constructors
class MainScreen extends GetResponsiveView<MainScreenController>
    with ConsoleMixin {
  MainScreen({Key? key})
      : super(
          key: key,
          settings: const ResponsiveScreenSettings(
            desktopChangePoint: 800,
          ),
        );

  Widget itemBuilder(context, index) => ItemTile(
        controller.data[index],
        key: GlobalKey(),
      );

  void searchPressed() async {
    controller.searchDelegate = ItemsSearchDelegate();

    await showSearch(
      context: Get.context!,
      delegate: controller.searchDelegate!,
    );

    controller.searchDelegate = null;
  }

  @override
  Widget? builder() {
    final listView = Obx(
      () => ListView.separated(
        shrinkWrap: true,
        itemCount: controller.data.length,
        itemBuilder: itemBuilder,
        separatorBuilder: (context, index) => const Divider(height: 0),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );

    final content = controller.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: LineIcons.seedling,
        message: 'no_items'.tr,
        child: DrawerMenuController.to.boxFilter.value == HiveBoxFilter.all
            ? ContextMenuButton(
                controller.menuItemsCategory,
                child: TextButton.icon(
                  icon: const Icon(LineIcons.plus),
                  label: Text(
                    'add_item'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {},
                ),
              )
            : null,
      ),
    );

    final appBar = AppBar(
      centerTitle: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(Images.logo, height: 17),
          const SizedBox(width: 10),
          const Text(
            kAppName,
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(LineIcons.search),
          onPressed: searchPressed,
        ),
        Obx(
          () => ContextMenuButton(
            controller.menuItemsSort,
            initialItem: controller.menuItemsSort.firstWhere(
              (e) => controller.sortOrder.value.name
                  .toLowerCase()
                  .contains(e.title.toLowerCase().replaceAll(' ', '')),
            ),
            child: IconButton(
              icon: const Icon(LineIcons.sort),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );

    final floatingActionButton = ContextMenuButton(
      controller.menuItemsCategory,
      child: FloatingActionButton(
        child: const Icon(LineIcons.plus),
        onPressed: () {},
      ),
    );

    if (screen.screenType == ScreenType.Desktop) {
      return Row(
        children: [
          const SizedBox(width: 240.0, child: DrawerMenu()),
          Container(width: 0.5, color: Colors.black),
          Expanded(
            child: Scaffold(
              key: controller.scaffoldKey,
              appBar: appBar,
              body: content,
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
