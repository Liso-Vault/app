import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:app_core/widgets/busy_indicator.widget.dart';
import 'package:app_core/widgets/remote_image.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:liso/core/persistence/persistence.dart';

import '../general/centered_placeholder.widget.dart';
import '../menu/menu.button.dart';
import '../menu/menu.item.dart';
import 'categories.controller.dart';
import 'categories_screen.controller.dart';

class CategoriesScreen extends StatelessWidget with ConsoleMixin {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoriesScreenController());
    final categoriesController = Get.find<CategoriesController>();

    Widget itemBuilder(context, index) {
      final category = categoriesController.data[index];

      void delete() async {
        category.metadata = await category.metadata!.getUpdated();
        category.deleted = true;
        await category.save();
        AppPersistence.to.changes.val++;
        categoriesController.load();
      }

      void confirmDelete() async {
        final dialogContent = Text(
          'Are you sure you want to delete the category "${category.name}"?',
        );

        Get.dialog(AlertDialog(
          title: const Text('Delete Category'),
          content: isSmallScreen
              ? dialogContent
              : SizedBox(width: 450, child: dialogContent),
          actions: [
            TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
            TextButton(
              onPressed: () {
                delete();
                Get.back();
              },
              child: Text('confirm_delete'.tr),
            ),
          ],
        ));
      }

      final menuItems = [
        ContextMenuItem(
          title: 'delete'.tr,
          leading: Icon(Iconsax.trash_outline, size: popupIconSize),
          onSelected: confirmDelete,
        ),
      ];

      return ListTile(
        onTap: () => controller.edit(category),
        enabled: !category.isReserved,
        title: Text(category.reservedName),
        subtitle: category.reservedDescription.isNotEmpty
            ? Text(category.reservedDescription)
            : null,
        leading: category.iconUrl.isEmpty
            ? const Icon(Iconsax.category_outline)
            : RemoteImage(
                url: category.iconUrl,
                width: 35,
                alignment: Alignment.centerLeft,
              ),
        trailing: ContextMenuButton(
          menuItems,
          child: const Icon(LineAwesome.ellipsis_v_solid),
        ),
      );
    }

    final listView = Obx(
      () => ListView.builder(
        shrinkWrap: true,
        itemCount: categoriesController.data.length,
        itemBuilder: itemBuilder,
        physics: const AlwaysScrollableScrollPhysics(),
      ),
    );

    final content = categoriesController.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: Iconsax.category_outline,
        message: 'no_custom_categories'.tr,
      ),
    );

    final appBar = AppBar(
      title: Text('custom_categories'.tr),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
      actions: [
        TextButton(
          onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
          child: const Text('Help ?'),
        ),
      ],
    );

    final floatingActionButton = FloatingActionButton(
      onPressed: controller.create,
      child: const Icon(LineAwesome.plus_solid),
    );

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: content,
    );
  }
}
