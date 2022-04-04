import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
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
        title: Text('all_Items'.tr + controller.itemsCount),
        leading: const Icon(LineIcons.list),
        onTap: controller.filterAllItems,
        selected: controller.boxFilter == HiveBoxFilter.all,
      ),
      ObxValue(
        (RxBool data) => SwitchListTile(
          title: Text('favorites'.tr + controller.favoriteCount),
          value: data.value,
          secondary: const Icon(LineIcons.heart),
          onChanged: controller.filterFavoritesSwitch,
        ),
        controller.filterFavorites,
      ),
      ListTile(
        title: Text('archived'.tr + controller.archivedCount),
        leading: const Icon(LineIcons.archive),
        onTap: controller.filterArchived,
        selected: controller.boxFilter == HiveBoxFilter.archived,
      ),
      ListTile(
        title: Text('trash'.tr + controller.trashCount),
        leading: const Icon(LineIcons.trash),
        onTap: controller.filterTrash,
        selected: controller.boxFilter == HiveBoxFilter.trash,
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
                leading: Utils.categoryIcon(
                  _category,
                  color: Colors.white,
                ),
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
            title: const Text('Settings'),
            leading: const Icon(LineIcons.cog),
            onTap: () => Get.offAndToNamed(Routes.settings),
          ),
          ListTile(
            title: const Text('About'),
            leading: const Icon(LineIcons.infoCircle),
            onTap: () => Get.offAndToNamed(Routes.about),
          ),
        ],
      ),
    ];

    final darkTheme = FlexColorScheme.dark(
      scheme: FlexScheme.jungle,
    ).toTheme.copyWith(canvasColor: Colors.grey.shade900);

    return Theme(
      data: darkTheme,
      child: Drawer(
        child: ListView.builder(
          // workaround for https://github.com/flutter/flutter/issues/93862
          primary: false,
          shrinkWrap: true,
          itemBuilder: (context, index) => items[index],
          itemCount: items.length,
        ),
      ),
    );
  }
}
