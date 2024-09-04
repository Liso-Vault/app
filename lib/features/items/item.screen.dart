import 'package:app_core/globals.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/busy_indicator.widget.dart';
import 'package:app_core/widgets/remote_image.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/features/categories/categories.controller.dart';
import 'package:liso/features/general/widget_refresher.widget.dart';
import 'package:liso/features/groups/groups.controller.dart';
import 'package:liso/features/menu/menu.button.dart';
import 'package:liso/features/shared_vaults/shared_vault.controller.dart';
import 'package:liso/features/tags/tags_input.widget.dart';

import '../../core/hive/models/category.hive.dart';
import '../../core/hive/models/group.hive.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import 'item_screen.controller.dart';

class ItemScreen extends StatelessWidget with ConsoleMixin {
  const ItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ItemScreenController());
    final mode = Get.parameters['mode'].toString();

    final items = [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ICON
          Obx(
            () => ContextMenuButton(
              controller.menuItemsChangeIcon,
              enabled: controller.editMode.value,
              child: controller.iconUrl().isEmpty
                  ? AppUtils.categoryIcon(controller.category.value)
                  : RemoteImage(
                      url: controller.iconUrl(),
                      width: 30,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          // TITLE
          Expanded(
            child: Obx(
              () {
                if (controller.editMode.value) {
                  return TextFormField(
                    enabled: controller.editMode.value,
                    autofocus: mode == 'add',
                    controller: controller.titleController,
                    textCapitalization: TextCapitalization.words,
                    validator: (data) =>
                        data!.isNotEmpty ? null : 'required'.tr,
                    decoration: InputDecoration(
                      labelText: '${'title'.tr} *',
                      suffixIcon: ContextMenuButton(
                        controller.titleMenuItems,
                        child: const Icon(LineAwesome.ellipsis_v_solid),
                      ),
                    ),
                  );
                }

                return GestureDetector(
                  onSecondaryTap: () => Utils.copyToClipboard(
                    controller.titleController.text,
                  ),
                  child: InkWell(
                    onLongPress: () => Utils.copyToClipboard(
                      controller.titleController.text,
                    ),
                    child: TextFormField(
                      initialValue: controller.titleController.text,
                      enabled: false,
                      decoration: InputDecoration(labelText: '${'title'.tr} *'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 15),
      Obx(
        () => Visibility(
          visible: !controller.editMode.value &&
              controller.category.value == LisoItemCategory.otp.name,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generated OTP Code',
                style: TextStyle(color: themeColor, fontSize: 12),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Iconsax.copy_outline),
                    label: Text(controller.otpCode.value),
                    onPressed: () => Utils.copyToClipboard(
                      controller.otpCode.value,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      Text(
                        controller.otpRemainingSeconds.value.toString(),
                        style: const TextStyle(fontSize: 11),
                      )
                    ],
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        ),
      ),

      // -------- RENDER FIELDS AS WIDGETS -------- //
      Obx(
        () => ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // buildDefaultDragHandles: controller.canEdit,
          buildDefaultDragHandles: false,
          children: controller.widgets,
          onReorder: (int oldIndex, int newIndex) {
            if (oldIndex < newIndex) newIndex -= 1;
            // re-order widgets
            final widget = controller.widgets.removeAt(oldIndex);
            controller.widgets.insert(newIndex, widget);
          },
        ),
      ),
      // -------- RENDER FIELDS AS WIDGETS -------- //
      const SizedBox(height: 10),
      Obx(
        () => Visibility(
          visible: controller.editMode.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContextMenuButton(
                controller.menuFieldItems,
                sheetForSmallScreen: true,
                padding: EdgeInsets.zero,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Iconsax.add_circle_outline),
                  label: const Text('Custom Field'),
                ),
              ),
              const Divider(),
            ],
          ),
        ),
      ),
      Obx(
        () => Visibility(
          visible:
              controller.editMode.value || controller.attachments.isNotEmpty,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'attachments'.tr,
                style: TextStyle(color: themeColor, fontSize: 12),
              ),
              const SizedBox(height: 5),
              Opacity(
                opacity: controller.editMode.value ? 1.0 : 0.6,
                child: Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    ...controller.attachmentChips,
                  ],
                ),
              ),
              const Divider(),
            ],
          ),
        ),
      ),
      Obx(
        () => Visibility(
          visible: controller.editMode.value ||
              controller.tagsController.data.isNotEmpty,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TagsInput(
                label: 'Tags',
                enabled: controller.editMode.value,
                controller: controller.tagsController,
              ),
              const Divider(),
            ],
          ),
        ),
      ),
      Obx(
        () => Visibility(
          visible: AppPersistence.to.canShare &&
              ((!controller.editMode.value &&
                      controller.sharedVaultChips.isNotEmpty) ||
                  (controller.editMode.value &&
                      SharedVaultsController.to.data.isNotEmpty)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'shared_vaults'.tr,
                style: TextStyle(color: themeColor, fontSize: 12),
              ),
              const SizedBox(height: 5),
              Opacity(
                opacity: controller.editMode.value ? 1.0 : 0.6,
                child: Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    ...controller.sharedVaultChips,
                  ],
                ),
              ),
              const Divider(),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      Obx(
        () {
          final dropdownRefresher = Get.put(WidgetRefresherController());
          var groupId = controller.groupId.value.isNotEmpty
              ? controller.groupId.value
              : GroupsController.to.reserved.first.id;

          return WidgetRefresher(
            controller: dropdownRefresher,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: groupId,
              onChanged: controller.reserved.value || !controller.editMode.value
                  ? null
                  : (value) async {
                      if (value == 'new-vault') {
                        controller.groupId.value =
                            GroupsController.to.reserved.first.id;
                        // hack to refresh dropdown text
                        dropdownRefresher.reload();
                        return await Utils.adaptiveRouteOpen(
                          name: AppRoutes.vaults,
                        );
                      }

                      controller.groupId.value = value!;
                      console.wtf('changed: $value');
                    },
              decoration: const InputDecoration(labelText: 'Vault'),
              items: {
                ...GroupsController.to.combined,
                HiveLisoGroup(
                  id: 'new-vault',
                  name: 'New Vault',
                  metadata: null,
                ),
              }
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e.id,
                      child: Text(e.reservedName),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
      const SizedBox(height: 20),
      Obx(
        () => DropdownButtonFormField<HiveLisoCategory>(
          isExpanded: true,
          value: controller.categoryObject,
          onChanged: controller.reserved.value || !controller.editMode.value
              ? null
              : (value) => controller.category.value = value!.id,
          decoration: const InputDecoration(labelText: 'Category'),
          items: [
            ...{...CategoriesController.to.combined, controller.categoryObject}
                .map((e) => DropdownMenuItem<HiveLisoCategory>(
                      value: e,
                      child: Text(e.reservedName),
                    ))
          ],
        ),
      ),
      const SizedBox(height: 10),
      ObxValue(
        (RxBool data) => CheckboxListTile(
          checkboxShape: const CircleBorder(),
          title: Text('favorite'.tr),
          value: data(),
          onChanged:
              controller.editMode.value ? (value) => data.value = value! : null,
        ),
        controller.favorite,
      ),
      ObxValue(
        (RxBool data) => CheckboxListTile(
          checkboxShape: const CircleBorder(),
          title: Text('protected'.tr),
          value: data(),
          onChanged:
              controller.editMode.value ? controller.onProtectedChanged : null,
        ),
        controller.protected,
      ),

      if (mode == 'view') ...[
        const SizedBox(height: 20),
        Text(
          'Modified ${controller.item?.updatedDateTimeFormatted}',
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          'Created ${controller.item?.createdDateTimeFormatted}',
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
      const SizedBox(height: 80),
    ];

    // if it's a custom category, use the title field as the app bar title
    String titleString = controller.categoryObject.reservedName;

    if (controller.categoryObject.id == LisoItemCategory.custom.name &&
        controller.titleController.text.isNotEmpty) {
      titleString = controller.titleController.text;
    }

    final appBar = AppBar(
      title: Text(titleString),
      leading: IconButton(
        onPressed: () async {
          if (await controller.canPop()) Get.back();
        },
        icon: Icon(
          isSmallScreen
              ? Iconsax.arrow_left_2_outline
              : LineAwesome.times_solid,
        ),
      ),
      actions: [
        if (!isSmallScreen) ...[
          Obx(
            () => Visibility(
              visible: controller.editMode.value,
              replacement: IconButton(
                onPressed: controller.editMode.toggle,
                icon: const Icon(LineAwesome.pen_solid),
              ),
              child: IconButton(
                onPressed: controller.joinedVaultItem
                    ? null
                    : mode == 'view'
                        ? controller.edit
                        : controller.add,
                icon: const Icon(Icons.check),
              ),
            ),
          ),
        ],
        if (mode == 'view') ...[
          Obx(
            () => ContextMenuButton(
              controller.menuItems,
              child: const Icon(LineAwesome.ellipsis_v_solid),
            ),
          ),
        ],
        const SizedBox(width: 10),
      ],
    );

    final fab = Obx(
      () => FloatingActionButton.extended(
        onPressed: () {
          if (!controller.editMode.value) {
            controller.editMode.toggle();
          } else {
            if (mode == 'view') {
              controller.edit();
            } else {
              controller.add();
            }
          }
        },
        icon: Icon(controller.editMode() ? Icons.check : LineAwesome.pen_solid),
        label: Text(controller.editMode() ? 'save'.tr : 'edit'.tr),
      ),
    );

    final content = Form(
      key: controller.formKey,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) => items[index],
      ),
    );

    final scaffold = Scaffold(
      appBar: appBar,
      floatingActionButton: isSmallScreen ? fab : null,
      // grey disabled fields
      body: Theme(
        data: Get.theme.copyWith(disabledColor: Colors.grey),
        child: controller.obx(
          (_) => content,
          onLoading: const BusyIndicator(),
        ),
      ),
    );

    return Obx(
      () => Visibility(
        visible: !controller.editMode.value,
        replacement: WillPopScope(
          onWillPop: controller.canPop,
          child: scaffold,
        ),
        child: scaffold,
      ),
    );
  }
}
