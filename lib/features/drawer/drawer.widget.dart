import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';

import '../../../core/utils/utils.dart';
import 'drawer_widget.controller.dart';

class DrawerMenu extends StatelessWidget with ConsoleMixin {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: Get.find<DrawerMenuController>(),
      builder: (DrawerMenuController controller) {
        final items = [
          // header,
          SimpleBuilder(
            builder: (_) => ExpansionTile(
              maintainState: true,
              title: Text(
                'groups'.tr.toUpperCase(),
                style: const TextStyle(fontSize: 13),
              ),
              onExpansionChanged: (expanded) =>
                  controller.groupsExpanded = expanded,
              initiallyExpanded: controller.groupsExpanded,
              children: controller.groupTiles,
            ),
          ),
          Obx(
            () => ListTile(
              leading: const Icon(LineIcons.list),
              onTap: controller.filterAllItems,
              selected: controller.filterAll,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('all_Items'.tr),
                  if (controller.itemsCount > 0) ...[
                    Chip(label: Text(controller.itemsCount.toString())),
                  ]
                ],
              ),
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
              leading: const FaIcon(FontAwesomeIcons.shieldHalved),
              onTap: controller.filterProtectedItems,
              selected: controller.filterProtected(),
            ),
          ),
          Obx(
            () => ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('trash'.tr),
                  if (controller.trashedCount > 0) ...[
                    Chip(label: Text(controller.trashedCount.toString())),
                  ]
                ],
              ),
              leading: const Icon(LineIcons.trash),
              onTap: controller.filterTrashedItems,
              selected: controller.filterTrashed(),
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
                title: Text('files'.tr),
                leading: const FaIcon(FontAwesomeIcons.fileLines),
                onTap: controller.files,
              ),
              ListTile(
                title: Text('wallet'.tr),
                leading: const FaIcon(LineIcons.wallet),
                enabled: false,
                // onTap: controller.files,
              ),
              ListTile(
                title: Text('browser'.tr),
                leading: const FaIcon(LineIcons.wiredNetwork),
                enabled: false,
                // onTap: controller.files,
              ),
              ListTile(
                title: Text('settings'.tr),
                leading: const Icon(LineIcons.cog),
                onTap: () {
                  if (Utils.isDrawerExpandable) {
                    Get.offAndToNamed(Routes.settings);
                  } else {
                    Utils.adaptiveRouteOpen(name: Routes.settings);
                  }
                },
              ),
              ListTile(
                title: Text('about'.tr),
                leading: const Icon(LineIcons.infoCircle),
                onTap: () {
                  // TODO: support offAndToNamed in adaptiveRouteOpen
                  if (Utils.isDrawerExpandable) {
                    Get.offAndToNamed(Routes.about);
                  } else {
                    Utils.adaptiveRouteOpen(name: Routes.about);
                  }
                },
              ),
            ],
          ),
          ExpansionTile(
            maintainState: true,
            initiallyExpanded: controller.toolsExpanded,
            onExpansionChanged: (expanded) =>
                controller.toolsExpanded = expanded,
            title: Text(
              'tools'.tr.toUpperCase(),
              style: const TextStyle(fontSize: 13),
            ),
            children: [
              ListTile(
                title: Text('breach_scanner'.tr),
                leading: const FaIcon(LineIcons.exclamationTriangle),
                enabled: false,
                // onTap: controller.files,
              ),
              ListTile(
                title: Text('password_health'.tr),
                leading: const FaIcon(LineIcons.laptopMedical),
                enabled: false,
                // onTap: controller.files,
              ),
              ListTile(
                title: Text('otp_generator'.tr),
                leading: const FaIcon(LineIcons.flask),
                enabled: false,
                // onTap: controller.files,
              ),
            ],
          )
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
