import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/persistence/persistence_builder.widget.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/premium_card.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/general/custom_chip.widget.dart';

import '../../core/persistence/persistence.dart';
import '../files/storage.service.dart';
import 'drawer_widget.controller.dart';

class DrawerMenu extends StatelessWidget with ConsoleMixin {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: Get.find<DrawerMenuController>(),
      builder: (DrawerMenuController controller) {
        final storage = Get.find<FileService>();

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
                  dense: isSmallScreen,
                  leading: const Icon(Iconsax.document_outline),
                  onTap: controller.filterAllItems,
                  selected: controller.filterAll,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('all_items'.tr),
                      if (controller.itemsCount > 0) ...[
                        CustomChip(
                          label: Text(
                            controller.itemsCount.toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Obx(
                () => ListTile(
                  dense: isSmallScreen,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('favorites'.tr),
                      if (controller.favoriteCount > 0) ...[
                        CustomChip(
                          label: Text(
                            controller.favoriteCount.toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                  leading: const Icon(Iconsax.heart_outline),
                  onTap: controller.filterFavoriteItems,
                  selected: controller.filterFavorites(),
                ),
              ),
              Obx(
                () => ListTile(
                  dense: isSmallScreen,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('protected'.tr),
                      if (controller.protectedCount > 0) ...[
                        CustomChip(
                          label: Text(
                            controller.protectedCount.toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                  leading: const Icon(Iconsax.lock_outline),
                  onTap: controller.filterProtectedItems,
                  selected: controller.filterProtected(),
                ),
              ),
              Obx(
                () => ListTile(
                  dense: isSmallScreen,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('password_health'.tr),
                      if (controller.fragilePasswordCount > 0) ...[
                        CustomChip(
                          color: Colors.amber,
                          label: Text(
                            controller.fragilePasswordCount.toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                  leading: const Icon(Iconsax.health_outline),
                  selected: controller.filterPasswordHealth(),
                  onTap: controller.filterPasswordHealthItems,
                ),
              ),
              Obx(
                () => ListTile(
                  dense: isSmallScreen,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('trash'.tr),
                      if (controller.trashedCount > 0) ...[
                        CustomChip(
                            label: Text(
                          controller.trashedCount.toString(),
                          style: const TextStyle(fontSize: 10),
                        )),
                      ],
                    ],
                  ),
                  leading: const Icon(Iconsax.trash_outline),
                  onTap: controller.filterTrashedItems,
                  selected: controller.filterTrashed(),
                ),
              ),
              // PersistenceBuilder(builder: (p, context) {
              //   if (!.proTester.val) {
              //     return const SizedBox.shrink();
              //   }

              //   return Obx(
              //     () => ListTile(
              //dense: isSmallScreen,
              //       selected: controller.filterDeleted(),
              //       selectedColor: Colors.red,
              //       leading: const Icon(Iconsax.slash),
              //       onTap: controller.filterDeletedItems,
              //       title: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           const Text('Deleted'),
              //           if (controller.deletedCount > 0) ...[
              //             Chip(label: Text(controller.deletedCount.toString())),
              //           ],
              //         ],
              //       ),
              //     ),
              //   );
              // }),
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
              const PremiumCard(),
              PersistenceBuilder(
                builder: (p, context) => AppPersistence.to.sync.val
                    ? ListTile(
                        dense: isSmallScreen,
                        leading: const Icon(Iconsax.document_cloud_outline),
                        onTap: () => Utils.adaptiveRouteOpen(
                          name: AppRoutes.s3Explorer,
                          parameters: {'type': 'explorer'},
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('files'.tr),
                            Obx(
                              () => CustomChip(
                                label: Text(
                                  '${filesize(storage.rootInfo.value.data.size, 0)}/${filesize(limits.storageSize, 0)}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                            // Chip(
                            //   label: Obx(
                            //     () => Text(
                            //       '${filesize(storage.rootInfo.value.data.size, 0)}/${filesize(limits.storageSize, 0)}',
                            //       style: const TextStyle(fontSize: 10),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Obx(
                            () => LinearProgressIndicator(
                              value:
                                  storage.rootInfo.value.data.size.toDouble() /
                                      limits.storageSize,
                              backgroundColor: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              // PersistenceBuilder(builder: (p, context) {
              //   if (!isCryptoSupported) {
              //     return const SizedBox.shrink();
              //   }

              //   return ListTile(
              //     dense: isSmallScreen,
              //     title: Text('wallet'.tr),
              //     leading: const Icon(Iconsax.wallet_1_outline),
              //     onTap: () => Utils.adaptiveRouteOpen(
              //       name: AppRoutes.wallet,
              //       method: 'offAndToNamed',
              //     ),
              //   );
              // }),
              ListTile(
                dense: isSmallScreen,
                title: Text('settings'.tr),
                leading: const Icon(Iconsax.setting_2_outline),
                onTap: () {
                  Get.closeOverlay();
                  Utils.adaptiveRouteOpen(name: Routes.settings);
                },
              ),
              ListTile(
                dense: isSmallScreen,
                title: Text('about'.tr),
                leading: const Icon(Iconsax.info_circle_outline),
                onTap: () {
                  Get.closeOverlay();
                  Utils.adaptiveRouteOpen(name: Routes.about);
                },
              ),
              const Divider(),
              ListTile(
                dense: isSmallScreen,
                title: Text('need_help'.tr),
                leading: const Icon(Iconsax.message_question_outline),
                onTap: () {
                  Get.closeOverlay();
                  Utils.adaptiveRouteOpen(name: Routes.feedback);
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
                dense: isSmallScreen,
                title: Text('encryption_tool'.tr),
                leading: const Icon(Iconsax.convert_3d_cube_outline),
                onTap: () {
                  Get.closeOverlay();
                  Utils.adaptiveRouteOpen(name: AppRoutes.cipher);
                },
              ),
              ListTile(
                dense: isSmallScreen,
                title: Text('password_generator'.tr),
                leading: const Icon(Iconsax.password_check_outline),
                onTap: () {
                  Get.closeOverlay();
                  Utils.adaptiveRouteOpen(
                    name: AppRoutes.passwordGenerator,
                    parameters: {'from': 'drawer'},
                  );
                },
              ),
              ListTile(
                dense: isSmallScreen,
                title: Text('seed_generator'.tr),
                leading: const Icon(Iconsax.key_outline),
                onTap: () {
                  Get.closeOverlay();
                  Utils.adaptiveRouteOpen(
                    name: AppRoutes.seedGenerator,
                    parameters: {'from': 'drawer'},
                  );
                },
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
                dense: isSmallScreen,
                title: Text('clear_filters'.tr),
                leading: const Icon(Iconsax.slash_outline),
                onTap: controller.clearFilters,
              ),
            ),
          ),
        ];

        return Drawer(
          shape: const BeveledRectangleBorder(),
          width: isSmallScreen ? Get.mediaQuery.size.width - 50 : null,
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
