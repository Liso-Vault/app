import 'package:console_mixin/console_mixin.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/general/section.widget.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../../core/utils/utils.dart';
import '../../core/persistence/persistence_builder.widget.dart';
import 'drawer_widget.controller.dart';

class DrawerMenu extends StatelessWidget with ConsoleMixin {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: Get.find<DrawerMenuController>(),
      builder: (DrawerMenuController controller) {
        final items = [
          ListTile(
            title: const Text('Debug'),
            onTap: () {
              //
            },
          ),
          Obx(
            () => ExpansionTile(
              maintainState: true,
              title: Text(
                'vaults'.tr.toUpperCase(),
                style: const TextStyle(fontSize: 13),
              ),
              onExpansionChanged: (expanded) =>
                  controller.groupsExpanded = expanded,
              initiallyExpanded: controller.groupsExpanded,
              children: [...controller.groupTiles],
            ),
          ),
          PersistenceBuilder(
            builder: (p, context) => Persistence.to.canShare
                ? Obx(
                    () => ExpansionTile(
                      maintainState: true,
                      title: Text(
                        'shared_vaults'.tr.toUpperCase(),
                        style: const TextStyle(fontSize: 13),
                      ),
                      onExpansionChanged: (expanded) =>
                          controller.sharedVaultsExpanded = expanded,
                      initiallyExpanded: controller.sharedVaultsExpanded,
                      children: [...controller.sharedVaultsTiles],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          PersistenceBuilder(
            builder: (p, context) => Persistence.to.canShare
                ? Obx(
                    () => ExpansionTile(
                      maintainState: true,
                      title: Text(
                        'joined_vaults'.tr.toUpperCase(),
                        style: const TextStyle(fontSize: 13),
                      ),
                      onExpansionChanged: (expanded) =>
                          controller.joinedVaultsExpanded = expanded,
                      initiallyExpanded: controller.joinedVaultsExpanded,
                      children: [...controller.joinedVaultsTiles],
                    ),
                  )
                : const SizedBox.shrink(),
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
              if (kDebugMode) ...[
                Obx(
                  () => ListTile(
                    selected: controller.filterDeleted(),
                    selectedColor: Colors.red,
                    leading: const Icon(Iconsax.slash),
                    onTap: controller.filterDeletedItems,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Deleted'),
                        if (controller.deletedCount > 0) ...[
                          Chip(label: Text(controller.deletedCount.toString())),
                        ],
                      ],
                    ),
                  ),
                ),
              ]
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
            maintainState: true,
            title: Text(
              'tags'.tr.toUpperCase(),
              style: const TextStyle(fontSize: 13),
            ),
            initiallyExpanded: controller.tagsExpanded,
            onExpansionChanged: (expanded) =>
                controller.tagsExpanded = expanded,
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
          ),
          ExpansionTile(
            maintainState: true,
            initiallyExpanded: true,
            title: Text(
              'app'.tr.toUpperCase(),
              style: const TextStyle(fontSize: 13),
            ),
            children: [
              PersistenceBuilder(
                builder: (p, context) => Persistence.to.canSync &&
                        (!GetPlatform.isIOS || Persistence.to.proTester.val)
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
                                  '${filesize(S3Service.to.storageSize.value, 0)}/${filesize(WalletService.to.limits.storageSize, 0)}',
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
                                  WalletService.to.limits.storageSize,
                              backgroundColor: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              PersistenceBuilder(
                builder: (p, context) => Column(
                  children: [
                    if (!GetPlatform.isIOS || Persistence.to.proTester.val) ...[
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
                leading: const Icon(Iconsax.setting_2),
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
                title: Text('otp_generator'.tr),
                leading: const Icon(Iconsax.key),
                onTap: () => Utils.adaptiveRouteOpen(
                  name: Routes.otp,
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
            ],
          ),
          Obx(
            () => Visibility(
              visible: !controller.filterAll,
              child: ListTile(
                title: const Text('Clear Filters'),
                leading: const Icon(Iconsax.slash),
                onTap: controller.clearFilters,
              ),
            ),
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
