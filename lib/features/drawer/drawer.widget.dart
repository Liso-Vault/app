import 'package:console_mixin/console_mixin.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/files/storage.service.dart';
import 'package:liso/features/general/pro.widget.dart';
import 'package:liso/features/files/sync.service.dart';

import '../../../core/utils/utils.dart';
import '../../core/persistence/persistence_builder.widget.dart';
import '../pro/pro.controller.dart';
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
              'items'.tr.toUpperCase(),
              style: const TextStyle(fontSize: 13),
            ),
            initiallyExpanded: true,
            // childrenPadding: EdgeInsets.zero,
            children: [
              Obx(
                () => ListTile(
                  leading: const Icon(Iconsax.document),
                  onTap: controller.filterAllItems,
                  selected: controller.filterAll,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('All Items'),
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
                      Text('password_health'.tr),
                      if (controller.fragilePasswordCount > 0) ...[
                        Theme(
                          data: Get.theme.copyWith(
                            chipTheme: Get.theme.chipTheme.copyWith(
                              labelStyle: const TextStyle(color: Colors.amber),
                            ),
                          ),
                          child: Chip(
                            label: Text(
                              controller.fragilePasswordCount.toString(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  leading: const Icon(Iconsax.health),
                  selected: controller.filterPasswordHealth(),
                  onTap: controller.filterPasswordHealthItems,
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
              PersistenceBuilder(builder: (p, context) {
                if (!p.proTester.val) {
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
                builder: (p, context) => p.sync.val
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
                                  '${filesize(StorageService.to.rootInfo.value.data.size, 0)}/${filesize(ProController.to.limits.storageSize, 0)}',
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
                              value: StorageService.to.rootInfo.value.data.size
                                      .toDouble() /
                                  ProController.to.limits.storageSize,
                              backgroundColor: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              PersistenceBuilder(builder: (p, context) {
                if (!isCryptoSupported) {
                  return const SizedBox.shrink();
                }

                return ListTile(
                  title: Text('wallet'.tr),
                  leading: const Icon(Iconsax.wallet_1),
                  onTap: () => Utils.adaptiveRouteOpen(
                    name: Routes.wallet,
                    method: 'offAndToNamed',
                  ),
                );
              }),
              // ListTile(
              //   title: Text('browser'.tr),
              //   leading: const Icon(Iconsax.chrome),
              //   enabled: false,
              //   // onTap: controller.browser,
              // ),
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
              const Divider(),
              PersistenceBuilder(
                builder: (p, context) => Obx(
                  () => Column(
                    children: [
                      ListTile(
                        title: Row(
                          children: [
                            if (!ProController.to.isPro) ...[
                              const Text(
                                'Try ',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                            ],
                            const ProText(size: 16)
                          ],
                        ),
                        subtitle: Text(
                          ProController.to.isPro
                              ? 'Active'
                              : 'Unlock All Access',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        leading: Icon(LineIcons.rocket, color: proColor),
                        onTap: () => ProController.to.isPro
                            ? Utils.openUrl(
                                ProController.to.info.value.managementURL!,
                              )
                            : Utils.adaptiveRouteOpen(
                                name: Routes.upgrade,
                                method: 'offAndToNamed',
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: const Text('Need Help?'),
                subtitle: const Text("Don't hesitate to contact us"),
                leading: const Icon(Iconsax.message),
                onTap: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
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
                title: const Text('Encryption Tool'),
                leading: const Icon(Iconsax.convert_3d_cube),
                onTap: () => Utils.adaptiveRouteOpen(
                  name: Routes.cipher,
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
              // ListTile(
              //   title: Text('breach_scanner'.tr),
              //   leading: const Icon(Iconsax.warning_2),
              //   enabled: false,
              //   // onTap: controller.files,
              // ),
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
