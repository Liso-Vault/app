import 'package:console_mixin/console_mixin.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/persistence/persistence.dart';
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
          ExpansionTile(
            maintainState: true,
            title: Text(
              'vaults'.tr.toUpperCase(),
              style: const TextStyle(fontSize: 13),
            ),
            onExpansionChanged: (expanded) =>
                controller.groupsExpanded = expanded,
            initiallyExpanded: controller.groupsExpanded,
            children: [
              Obx(() => Column(children: controller.groupTiles)),
              PersistenceBuilder(builder: (_, context) {
                if (!Persistence.to.canShare) return const SizedBox.shrink();

                return Obx(
                  () => Column(
                    children: [
                      const Section(
                        text: 'Shared',
                        padding: EdgeInsets.symmetric(horizontal: 18),
                      ),
                      ...controller.sharedVaultsTiles,
                      const Section(
                        text: 'Joined',
                        padding: EdgeInsets.symmetric(horizontal: 18),
                      ),
                      ...controller.joinedVaultsTiles
                    ],
                  ),
                );
              }),
            ],
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
              PersistenceBuilder(builder: (_, context) {
                if (!Persistence.to.proTester.val) {
                  return const SizedBox.shrink();
                }

                return Obx(
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
                );
              }),
            ],
          ),
          ExpansionTile(
            initiallyExpanded: controller.categoriesExpanded,
            title: Text(
              'categories'.tr.toUpperCase(),
              style: const TextStyle(fontSize: 13),
            ),
            children: controller.categoryTiles,
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
            children: controller.tagTiles,
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
                builder: (p, context) => Persistence.to.sync.val
                    ? ListTile(
                        leading: const Icon(Iconsax.document_cloud),
                        onTap: () => Utils.adaptiveRouteOpen(
                          name: Routes.s3Explorer,
                          parameters: {'type': 'explorer'},
                        ),
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
                    ListTile(
                      title: Text('wallet'.tr),
                      leading: const Icon(Iconsax.wallet_1),
                      onTap: () => Utils.adaptiveRouteOpen(
                        name: Routes.wallet,
                        method: 'offAndToNamed',
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('browser'.tr),
                leading: const Icon(Iconsax.chrome),
                enabled: false,
                // onTap: controller.browser,
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
                title: const Text('Cipher Tool'),
                leading: const Icon(Iconsax.convert_3d_cube),
                onTap: () => Utils.adaptiveRouteOpen(
                  name: Routes.cipher,
                  method: 'offAndToNamed',
                ),
              ),
              ListTile(
                title: Text('otp_generator'.tr),
                leading: const Icon(Iconsax.code),
                onTap: () => Utils.adaptiveRouteOpen(
                  name: Routes.otp,
                  method: 'offAndToNamed',
                ),
              ),
              ListTile(
                title: Text('password_generator'.tr),
                leading: const Icon(Iconsax.password_check),
                onTap: () => Utils.adaptiveRouteOpen(
                  name: Routes.passwordGenerator,
                  method: 'offAndToNamed',
                  parameters: {'from': 'drawer'},
                ),
              ),
              ListTile(
                title: Text('seed_generator'.tr),
                leading: const Icon(Iconsax.key),
                onTap: () => Utils.adaptiveRouteOpen(
                  name: Routes.seedGenerator,
                  method: 'offAndToNamed',
                  parameters: {'from': 'drawer'},
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
                leading: const Icon(Iconsax.health),
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
