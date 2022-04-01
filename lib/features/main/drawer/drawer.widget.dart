import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/hive.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/main/main_screen.controller.dart';

import '../../../core/utils/utils.dart';

class ZDrawer extends StatelessWidget with ConsoleMixin {
  const ZDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final address = masterWallet!.privateKey.address.hexEip55;

    final header = DrawerHeader(
      child: Center(
        child: InkWell(
          child: const Text('Some text here'),
          onTap: () {
            //
          },
        ),
      ),
    );

    // CATEGORIES
    // distinctly filter only used categories
    final Set<String> categoriesSet = {};

    HiveManager.items!.values
        .where((e) => categoriesSet.add(e.category))
        .toList();

    // TAGS
    // distinctly filter tags
    final tags = HiveManager.items!.values
        .map((e) => e.tags.where((x) => x.isNotEmpty).toList())
        .toSet();

    final Set<String> tagsSet = {};

    if (tags.isNotEmpty) {
      tagsSet.addAll(tags.reduce((a, b) => a + b).toSet());
    }

    final items = [
      header,
      ListTile(
        title: Text('allItems'.tr),
        leading: const Icon(LineIcons.list),
        onTap: () {
          filterFavorites = false;
          filterCategory = null;
          filterTag = '';
          MainScreenController.to.reload();
          Get.back();
        },
      ),
      SwitchListTile(
        title: Text('favorites'.tr),
        value: filterFavorites,
        secondary: const Icon(LineIcons.heart),
        onChanged: (bool? value) {
          filterFavorites = value!;
          filterTag = '';
          MainScreenController.to.reload();
          Get.back();
        },
      ),
      ExpansionTile(
        title: Text(
          'categories'.tr.toUpperCase(),
          style: const TextStyle(fontSize: 13),
        ),
        initiallyExpanded: true,
        children: [
          ...categoriesSet
              .map(
                (e) => ListTile(
                  title: Text(e.tr),
                  leading: Utils.categoryIcon(
                    LisoItemCategory.values.byName(e),
                    color: Colors.white,
                  ),
                  onTap: () {
                    filterCategory = e == 'allItems'
                        ? null
                        : LisoItemCategory.values.byName(e);
                    MainScreenController.to.reload();
                    Get.back();
                  },
                ),
              )
              .toList(),
        ],
      ),
      ExpansionTile(
        title: Text(
          'tags'.tr.toUpperCase(),
          style: const TextStyle(fontSize: 13),
        ),
        initiallyExpanded: true,
        children: [
          ...tagsSet
              .map(
                (e) => ListTile(
                  title: Text(e.tr),
                  leading: const Icon(LineIcons.tag),
                  onTap: () {
                    filterTag = e;
                    MainScreenController.to.reload();
                    Get.back();
                  },
                ),
              )
              .toList(),
        ],
      ),
      ExpansionTile(
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
