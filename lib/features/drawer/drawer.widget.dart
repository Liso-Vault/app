import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/s3/s3.service.dart';

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
          // ExpansionTile(
          //   maintainState: true,
          //   title: const Text(
          //     'Networks',
          //     style: TextStyle(fontSize: 13),
          //   ),
          //   onExpansionChanged: (expanded) =>
          //       controller.networksExpanded = expanded,
          //   initiallyExpanded: controller.networksExpanded,
          //   children: const [
          //     ListTile(
          //       title: Text('Ethereum'),
          //       leading: FaIcon(LineIcons.ethereum),
          //       enabled: false,
          //     ),
          //     ListTile(
          //       title: Text('Polygon'),
          //       leading: FaIcon(LineIcons.ethereum),
          //       enabled: false,
          //     ),
          //     ListTile(
          //       title: Text('Binance Chain'),
          //       leading: FaIcon(LineIcons.ethereum),
          //       enabled: false,
          //     ),
          //     ListTile(
          //       title: Text('Solana'),
          //       leading: FaIcon(LineIcons.ethereum),
          //       enabled: false,
          //     ),
          //     ListTile(
          //       title: Text('Avalanche'),
          //       leading: FaIcon(LineIcons.ethereum),
          //       enabled: false,
          //     ),
          //   ],
          // ),
          SimpleBuilder(
            builder: (_) => ExpansionTile(
              maintainState: true,
              title: Text(
                'vaults'.tr.toUpperCase(),
                style: const TextStyle(fontSize: 13),
              ),
              onExpansionChanged: (expanded) =>
                  controller.groupsExpanded = expanded,
              initiallyExpanded: controller.groupsExpanded,
              children: controller.groupTiles,
            ),
          ),
          ExpansionTile(
            maintainState: true,
            title: Text(
              'items'.tr.toUpperCase(),
              style: const TextStyle(fontSize: 13),
            ),
            initiallyExpanded: true,
            children: [
              Obx(
                () => ListTile(
                  leading: const Icon(LineIcons.list),
                  onTap: controller.filterAllItems,
                  selected: controller.filterAll,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('all'.tr),
                      if (controller.itemsCount > 0) ...[
                        Chip(label: Text(controller.itemsCount.toString())),
                      ],
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
                      ],
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
                      ],
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
                      ],
                    ],
                  ),
                  leading: const Icon(LineIcons.trash),
                  onTap: controller.filterTrashedItems,
                  selected: controller.filterTrashed(),
                ),
              ),
            ],
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
              SimpleBuilder(
                builder: (_) => PersistenceService.to.sync.val &&
                        !GetPlatform.isIOS
                    ? ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('files'.tr),
                            Chip(
                              label: Obx(
                                () => Text(
                                  filesize(S3Service.to.storageSize.value, 0) +
                                      '/${filesize(ConfigService.to.app.settings.maxStorageSize, 0)}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Obx(
                            () => LinearProgressIndicator(
                              value: S3Service.to.storageSize.value.toDouble() /
                                  ConfigService.to.app.settings.maxStorageSize,
                            ),
                          ),
                        ),
                        leading: const FaIcon(FontAwesomeIcons.fileLines),
                        onTap: controller.files,
                      )
                    : const SizedBox.shrink(),
              ),
              SimpleBuilder(
                builder: (_) => Column(
                  children: [
                    if (!GetPlatform.isIOS ||
                        PersistenceService.to.proTester.val) ...[
                      ListTile(
                        title: Text('wallet'.tr),
                        leading: const FaIcon(LineIcons.wallet),
                        onTap: () => Utils.adaptiveRouteOpen(
                          name: Routes.wallet,
                          method: 'offAndToNamed',
                        ),
                      ),
                      const ListTile(
                        title: Text('NFTs'),
                        leading: FaIcon(LineIcons.icons),
                        enabled: false,
                        // onTap: controller.files,
                      ),
                    ],
                  ],
                ),
              ),
              // ListTile(
              //   title: Text('browser'.tr),
              //   leading: const FaIcon(LineIcons.wiredNetwork),
              //   enabled: false,
              //   // onTap: controller.files,
              // ),
              ListTile(
                title: Text('settings'.tr),
                leading: const Icon(LineIcons.cog),
                onTap: () => Utils.adaptiveRouteOpen(
                  name: Routes.settings,
                  method: 'offAndToNamed',
                ),
              ),
              ListTile(
                title: Text('about'.tr),
                leading: const Icon(LineIcons.infoCircle),
                onTap: () => Utils.adaptiveRouteOpen(
                  name: Routes.about,
                  method: 'offAndToNamed',
                ),
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
