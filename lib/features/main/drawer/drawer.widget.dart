import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/general/custom_chip.widget.dart';
import 'package:liso/features/main/drawer/drawer_widget.controller.dart';

import '../../../core/utils/utils.dart';

class ZDrawer extends GetView<DrawerWidgetController> with ConsoleMixin {
  const ZDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final address = masterWallet!.privateKey.address.hexEip55;

    final header = DrawerHeader(
      child: Center(
        child: InkWell(
          child: const Text('HEADER HERE'),
          onTap: () {
            //
          },
        ),
      ),
    );

    final items = [
      header,
      ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('all_Items'.tr),
            CustomChip(label: Text(controller.itemsCount)),
          ],
        ),
        leading: const Icon(LineIcons.list),
        onTap: controller.filterAllItems,
        selected: controller.boxFilter() == HiveBoxFilter.all,
      ),
      ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('favorites'.tr),
            CustomChip(label: Text(controller.favoriteCount)),
          ],
        ),
        leading: controller.filterFavorites()
            ? const FaIcon(FontAwesomeIcons.solidHeart, color: Colors.pink)
            : const FaIcon(FontAwesomeIcons.heart),
        onTap: controller.filterFavoriteItems,
        selected: controller.filterFavorites(),
      ),
      ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('protected'.tr),
            CustomChip(label: Text(controller.protectedCount)),
          ],
        ),
        leading: controller.filterProtected()
            ? const FaIcon(FontAwesomeIcons.shield, color: kAppColor)
            : const FaIcon(FontAwesomeIcons.shieldHalved),
        onTap: controller.filterProtectedItems,
        selected: controller.filterProtected(),
      ),
      ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('archived'.tr),
            CustomChip(label: Text(controller.archivedCount)),
          ],
        ),
        leading: const Icon(LineIcons.archive),
        onTap: controller.filterArchivedItems,
        selected: controller.boxFilter() == HiveBoxFilter.archived,
      ),
      ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('trash'.tr),
            CustomChip(label: Text(controller.trashCount)),
          ],
        ),
        leading: const Icon(LineIcons.trash),
        onTap: controller.filterTrashItems,
        selected: controller.boxFilter() == HiveBoxFilter.trash,
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

              return ListTile(
                title: Text(e.tr),
                leading: Utils.categoryIcon(_category),
                onTap: () => controller.filterByCategory(e),
                selected: _category == controller.filterCategory,
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
                (e) => ListTile(
                  title: Text(e),
                  leading: const Icon(LineIcons.tag),
                  onTap: () => controller.filterByTag(e),
                  selected: e == controller.filterTag,
                ),
              )
              .toList(),
        ],
        onExpansionChanged: (expanded) => controller.tagsExpanded = expanded,
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
            onTap: () => Get.offAndToNamed(Routes.settings),
          ),
          ListTile(
            title: Text('about'.tr),
            leading: const Icon(LineIcons.infoCircle),
            onTap: () => Get.offAndToNamed(Routes.about),
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
  }
}
