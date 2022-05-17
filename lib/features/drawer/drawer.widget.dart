import 'package:console_mixin/console_mixin.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/services/persistence.service.dart';
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
          //       leading: Icon(LineIcons.ethereum),
          //       enabled: false,
          //     ),
          //     ListTile(
          //       title: Text('Polygon'),
          //       leading: Icon(LineIcons.ethereum),
          //       enabled: false,
          //     ),
          //     ListTile(
          //       title: Text('Binance Chain'),
          //       leading: Icon(LineIcons.ethereum),
          //       enabled: false,
          //     ),
          //     ListTile(
          //       title: Text('Solana'),
          //       leading: Icon(LineIcons.ethereum),
          //       enabled: false,
          //     ),
          //     ListTile(
          //       title: Text('Avalanche'),
          //       leading: Icon(LineIcons.ethereum),
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
                  leading: const Icon(Iconsax.document),
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
                  leading: const Icon(Iconsax.heart),
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
                  leading: const Icon(Iconsax.lock),
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
                  leading: const Icon(Iconsax.trash),
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
                  final category = LisoItemCategory.values.byName(e);

                  return Obx(
                    () => ListTile(
                      title: Text(e.tr),
                      leading: Utils.categoryIcon(category),
                      onTap: () => controller.filterByCategory(e),
                      selected: category == controller.filterCategory.value,
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
                        leading: const Icon(Iconsax.tag),
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
            initiallyExpanded: true,
            title: Text(
              'app'.tr.toUpperCase(),
              style: const TextStyle(fontSize: 13),
            ),
            children: [
              SimpleBuilder(
                builder: (_) => PersistenceService.to.sync.val &&
                        (!GetPlatform.isIOS ||
                            PersistenceService.to.proTester.val)
                    ? ListTile(
                        leading: const Icon(Iconsax.document_cloud),
                        onTap: controller.files,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('files'.tr),
                            Chip(
                              label: Obx(
                                () => Text(
                                  '${filesize(S3Service.to.storageSize.value, 0)}/${filesize(ConfigService.to.app.settings.maxStorageSize, 0)}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Obx(
                            () => LinearProgressIndicator(
                              value: S3Service.to.storageSize.value.toDouble() /
                                  ConfigService.to.app.settings.maxStorageSize,
                              backgroundColor: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                        ),
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
                        leading: const Icon(Iconsax.wallet_1),
                        onTap: () => Utils.adaptiveRouteOpen(
                          name: Routes.wallet,
                          method: 'offAndToNamed',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ListTile(
                title: Text('browser'.tr),
                leading: const Icon(Iconsax.chrome),
                enabled: false,
                // onTap: controller.files,
              ),
              ListTile(
                title: Text('settings'.tr),
                leading: const Icon(Iconsax.setting_3),
                onTap: () => Utils.adaptiveRouteOpen(
                  name: Routes.settings,
                  method: 'offAndToNamed',
                ),
              ),
              ListTile(
                title: Text('about'.tr),
                leading: const Icon(Iconsax.info_circle),
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
                title: const Text('Cipher'),
                leading: const Icon(Iconsax.convert_3d_cube),
                onTap: () => Utils.adaptiveRouteOpen(
                  name: Routes.cipher,
                  method: 'offAndToNamed',
                ),
              ),
              ListTile(
                title: Text('breach_scanner'.tr),
                leading: const Icon(Iconsax.warning_2),
                enabled: false,
                // onTap: controller.files,
              ),
              ListTile(
                title: Text('password_health'.tr),
                leading: const Icon(Iconsax.password_check),
                enabled: false,
                // onTap: controller.files,
              ),
              ListTile(
                title: Text('otp_generator'.tr),
                leading: const Icon(Iconsax.key),
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
