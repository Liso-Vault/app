import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/features/general/centered_placeholder.widget.dart';
import 'package:liso/features/main/item.tile.dart';
import 'package:liso/resources/resources.dart';

import '../search/search.delegate.dart';
import 'drawer/drawer.widget.dart';
import 'drawer/drawer_widget.controller.dart';
import 'main_screen.controller.dart';

// ignore: use_key_in_widget_constructors
class MainScreen extends GetResponsiveView<MainScreenController>
    with ConsoleMixin {
  MainScreen({Key? key})
      : super(
          key: key,
          settings: const ResponsiveScreenSettings(
            desktopChangePoint: 800,
            tabletChangePoint: 600,
          ),
        );

  Widget itemBuilder(context, index) => ItemTile(controller.data[index]);

  @override
  Widget? builder() {
    final drawerController = Get.find<DrawerWidgetController>();

    final content = controller.obx(
      (_) => Obx(
        () => ListView.separated(
          shrinkWrap: true,
          itemCount: controller.data.length,
          itemBuilder: itemBuilder,
          separatorBuilder: (context, index) => const Divider(height: 0),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: LineIcons.seedling,
        message: 'no_items'.tr,
        child: drawerController.boxFilter.value == HiveBoxFilter.all
            ? TextButton.icon(
                label: Text('add_item'.tr),
                icon: const Icon(LineIcons.plus),
                onPressed: controller.add,
              )
            : null,
      ),
    );

    void searchPressed() async {
      controller.searchDelegate = ItemsSearchDelegate();

      await showSearch(
        context: Get.context!,
        delegate: controller.searchDelegate!,
      );

      controller.searchDelegate = null;
    }

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
        IconButton(
          icon: const Icon(LineIcons.sort),
          onPressed: controller.showSortSheet,
        ),
      ],
    );

    final floatingActionButton = FloatingActionButton(
      child: const Icon(LineIcons.plus),
      onPressed: controller.add,
    );

    if (screen.screenType == ScreenType.Desktop) {
      return Row(
        children: [
          const SizedBox(
            width: 240,
            child: DrawerMenu(),
          ),
          Container(width: 0.5, color: Colors.black),
          Expanded(
            child: Scaffold(
              appBar: appBar,
              floatingActionButton: Obx(
                () => DrawerWidgetController.to.boxFilter.value ==
                        HiveBoxFilter.all
                    ? floatingActionButton
                    : const SizedBox.shrink(),
              ),
              body: content,
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: appBar,
        body: content,
        floatingActionButton: floatingActionButton,
        drawer: const DrawerMenu(),
      );
    }
  }
}
