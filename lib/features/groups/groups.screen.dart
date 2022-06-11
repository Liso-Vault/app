import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/hive/hive_groups.service.dart';
import 'package:liso/features/general/remote_image.widget.dart';

import '../../core/utils/utils.dart';
import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import '../general/centered_placeholder.widget.dart';
import '../menu/menu.button.dart';
import '../menu/menu.item.dart';
import 'groups.controller.dart';
import 'groups_screen.controller.dart';

class GroupsScreen extends GetView<GroupsScreenController> with ConsoleMixin {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vaultsController = Get.find<GroupsController>();

    Widget itemBuilder(context, index) {
      final vault = vaultsController.filtered[index];

      void _confirmDelete() async {
        void _delete() async {
          // TODO: show the items binded to this group
          // TODO: if user proceeds, these items will also be deleted

          Get.back();
          await HiveGroupsService.to.box.delete(vault.key);
          vaultsController.load();
        }

        final dialogContent = Text(
          'Are you sure you want to delete the custom vault "${vault.name}"?',
        );

        Get.dialog(AlertDialog(
          title: const Text('Delete Custom Vault'),
          content: Utils.isDrawerExpandable
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
              onPressed: _delete,
              child: Text('confirm_delete'.tr),
            ),
          ],
        ));
      }

      final menuItems = [
        ContextMenuItem(
          title: 'delete'.tr,
          leading: const Icon(Iconsax.trash),
          onSelected: _confirmDelete,
        ),
      ];

      return ListTile(
        enabled: !vault.isReserved,
        title: Text(vault.reservedName),
        subtitle: vault.reservedDescription.isNotEmpty
            ? Text(vault.reservedDescription)
            : null,
        leading: vault.iconUrl.isEmpty
            ? const Icon(Iconsax.briefcase)
            : RemoteImage(
                url: vault.iconUrl,
                width: 35,
                alignment: Alignment.centerLeft,
              ),
        trailing: ContextMenuButton(
          menuItems,
          child: const Icon(LineIcons.verticalEllipsis),
        ),
      );
    }

    final listView = Obx(
      () => ListView.builder(
        shrinkWrap: true,
        itemCount: vaultsController.filtered.length,
        itemBuilder: itemBuilder,
        physics: const AlwaysScrollableScrollPhysics(),
      ),
    );

    final content = vaultsController.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: Iconsax.briefcase,
        message: 'no_custom_vaults'.tr,
      ),
    );

    final appBar = AppBar(
      title: Text('custom_vaults'.tr),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
    );

    final floatingActionButton = FloatingActionButton(
      onPressed: controller.create,
      child: const Icon(LineIcons.plus),
    );

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: content,
    );
  }
}
