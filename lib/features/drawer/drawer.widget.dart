import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/main/main_screen.controller.dart';

import '../../../core/utils/utils.dart';
import 'drawer_widget.controller.dart';

class DrawerMenu extends StatelessWidget with ConsoleMixin {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: Get.find<DrawerMenuController>(),
      builder: (DrawerMenuController controller) {
        final header = DrawerHeader(
          child: Center(
            child: InkWell(
              child: const Text('WALLET SECTION'),
              onTap: () {
                //
              },
            ),
          ),
        );

        final items = [
          header,
          Obx(
            () => ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('all_Items'.tr),
                  if (controller.itemsCount > 0) ...[
                    Chip(label: Text(controller.itemsCount.toString())),
                  ]
                ],
              ),
              leading: const Icon(LineIcons.list),
              onTap: controller.filterAllItems,
              selected: controller.boxFilter() == HiveBoxFilter.all,
            ),
          ),
          Obx(
            () => ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('favorites'.tr),
                  if (controller.favoriteCount > 0) ...[
                    Chip(label: Text(controller.favoriteCount.toString())),
                  ]
                ],
              ),
              leading: controller.filterFavorites()
                  ? const FaIcon(FontAwesomeIcons.solidHeart,
                      color: Colors.pink)
                  : const FaIcon(FontAwesomeIcons.heart),
              onTap: controller.filterFavoriteItems,
              selected: controller.filterFavorites(),
            ),
          ),
          Obx(
            () => ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('protected'.tr),
                  if (controller.protectedCount > 0) ...[
                    Chip(label: Text(controller.protectedCount.toString())),
                  ]
                ],
              ),
              leading: controller.filterProtected()
                  ? const FaIcon(FontAwesomeIcons.shield)
                  : const FaIcon(FontAwesomeIcons.shieldHalved),
              onTap: controller.filterProtectedItems,
              selected: controller.filterProtected(),
            ),
          ),
          ListTile(
            title: Text('files'.tr),
            leading: const FaIcon(FontAwesomeIcons.fileLines),
            onTap: controller.files,
          ),
          Obx(
            () => ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('archived'.tr),
                  if (controller.archivedCount > 0) ...[
                    Chip(label: Text(controller.archivedCount.toString())),
                  ]
                ],
              ),
              leading: const Icon(LineIcons.archive),
              onTap: controller.filterArchivedItems,
              selected: controller.boxFilter() == HiveBoxFilter.archived,
            ),
          ),
          Obx(
            () => ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('trash'.tr),
                  if (controller.trashCount > 0) ...[
                    Chip(label: Text(controller.trashCount.toString())),
                  ]
                ],
              ),
              leading: const Icon(LineIcons.trash),
              onTap: controller.filterTrashItems,
              selected: controller.boxFilter() == HiveBoxFilter.trash,
            ),
          ),
          ExpansionTile(
            initiallyExpanded: controller.categoriesExpanded,
            title: Text(
              'categories'.tr.toUpperCase(),
              style: const TextStyle(fontSize: 13),
            ),
            children: [
              ...controller.categories.map(
                (e) {
                  final _category = LisoItemCategory.values.byName(e);

                  return Obx(
                    () => ListTile(
                      title: Text(e.tr),
                      leading: Utils.categoryIcon(_category),
                      onTap: () => controller.filterByCategory(e),
                      selected: _category == controller.filterCategory.value,
                    ),
                  );
                },
              ).toList(),
            ],
            onExpansionChanged: (expanded) =>
                controller.categoriesExpanded = expanded,
          ),
          ExpansionTile(
            initiallyExpanded: controller.tagsExpanded,
            title: Text(
              'tags'.tr.toUpperCase(),
              style: const TextStyle(fontSize: 13),
            ),
            children: [
              ...controller.tags
                  .map(
                    (e) => Obx(
                      () => ListTile(
                        title: Text(e),
                        leading: const Icon(LineIcons.tag),
                        onTap: () => controller.filterByTag(e),
                        selected: e == controller.filterTag(),
                      ),
                    ),
                  )
                  .toList(),
            ],
            onExpansionChanged: (expanded) =>
                controller.tagsExpanded = expanded,
          ),
          ExpansionTile(
            maintainState: true,
            title: Text(
              'app'.tr.toUpperCase(),
              style: const TextStyle(fontSize: 13),
            ),
            initiallyExpanded: true,
            children: [
              ListTile(
                title: Text('settings'.tr),
                leading: const Icon(LineIcons.cog),
                onTap: () {
                  if (MainScreenController.to.expandableDrawer) {
                    Get.offAndToNamed(Routes.settings);
                  } else {
                    // Get.toNamed(Routes.settings);
                    Utils.adaptiveRouteOpen(name: Routes.settings);
                  }
                },
              ),
              ListTile(
                title: Text('about'.tr),
                leading: const Icon(LineIcons.infoCircle),
                onTap: () {
                  // TODO: support offAndToNamed in adaptiveRouteOpen
                  if (MainScreenController.to.expandableDrawer) {
                    Get.offAndToNamed(Routes.about);
                  } else {
                    Utils.adaptiveRouteOpen(name: Routes.about);
                  }
                },
              ),
            ],
          ),
        ];

        return Drawer(
          child: ListView.builder(
            // workaround for https://github.com/flutter/flutter/issues/93862
            primary: false,
            shrinkWrap: true,
            itemBuilder: (context, index) => items[index],
            itemCount: items.length,
          ),
        );
      },
    );
  }
}
