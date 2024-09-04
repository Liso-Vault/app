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
import 'package:liso/features/drawer/drawer_widget.controller.dart';
import 'package:liso/features/items/items.controller.dart';
import 'package:liso/features/items/items.service.dart';
import 'package:liso/features/main/main_screen.controller.dart';

import '../../core/hive/models/item.hive.dart';
import '../../core/persistence/persistence.dart';
import '../general/centered_placeholder.widget.dart';
import '../menu/menu.button.dart';
import '../menu/menu.item.dart';
import 'groups.controller.dart';
import 'groups_screen.controller.dart';

class GroupsScreen extends StatelessWidget with ConsoleMixin {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroupsScreenController());
    final groupsController = Get.find<GroupsController>();

    Widget itemBuilder(context, index) {
      final group = groupsController.data[index];

      void delete(Iterable<HiveLisoItem> items) async {
        // revert group filter
        final defaultGroupId = GroupsController.to.reserved.first.id;
        DrawerMenuController.to.filterGroupId.value = defaultGroupId;
        // move items to the default group
        await ItemsService.to.hideleteItems(items);
        group.metadata = await group.metadata!.getUpdated();
        group.deleted = true;
        await group.save();
        AppPersistence.to.changes.val++;
        groupsController.load();
        MainScreenController.to.load();
        console.info('deleted');
      }

      void confirmDelete() async {
        final items =
            ItemsController.to.data.where((e) => e.groupId == group.id);

        final dialogContent = Text(
          'Are you sure you want to delete the custom vault: "${group.name}" and it\'s ${items.length} items?',
        );

        Get.dialog(AlertDialog(
          title: const Text('Delete Custom Vault'),
          content: isSmallScreen
              ? dialogContent
              : SizedBox(
                  width: 450,
                  child: dialogContent,
                ),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () {
                delete(items);
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
        onTap: () => controller.edit(group),
        enabled: !group.isReserved,
        title: Text(group.reservedName),
        subtitle: group.reservedDescription.isNotEmpty
            ? Text(group.reservedDescription)
            : null,
        leading: group.iconUrl.isEmpty
            ? const Icon(Iconsax.briefcase_outline)
            : RemoteImage(
                url: group.iconUrl,
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
        itemCount: groupsController.data.length,
        itemBuilder: itemBuilder,
        physics: const AlwaysScrollableScrollPhysics(),
      ),
    );

    final content = groupsController.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: Iconsax.briefcase_outline,
        message: 'no_custom_vaults'.tr,
      ),
    );

    final appBar = AppBar(
      title: Text('custom_vaults'.tr),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
      actions: [
        TextButton(
          onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
          child: const Text('Need Help ?'),
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
