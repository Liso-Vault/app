import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/features/categories/categories.controller.dart';
import 'package:liso/features/groups/groups.controller.dart';
import 'package:liso/features/menu/menu.button.dart';
import 'package:liso/features/tags/tags_input.widget.dart';

import '../../core/hive/models/category.hive.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../general/busy_indicator.widget.dart';
import '../general/remote_image.widget.dart';
import 'item_screen.controller.dart';

class ItemScreen extends StatelessWidget with ConsoleMixin {
  const ItemScreen({Key? key}) : super(key: key);

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
              enabled: controller.canEdit,
              child: controller.iconUrl().isEmpty
                  ? Utils.categoryIcon(controller.category.value)
                  : RemoteImage(
                      url: controller.iconUrl(),
                      width: 30,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          // TITLE
          Obx(
            () => Expanded(
              child: TextFormField(
                enabled: controller.canEdit,
                autofocus: mode == 'add',
                controller: controller.titleController,
                textCapitalization: TextCapitalization.words,
                validator: (data) => data!.isNotEmpty ? null : 'required'.tr,
                decoration: InputDecoration(
                  labelText: '${'title'.tr} *',
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      // -------- RENDER FIELDS AS WIDGETS -------- //
      Obx(
        () => ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: controller.canEdit,
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
          visible: controller.canEdit,
          child: Align(
            alignment: Alignment.centerLeft,
            child: ContextMenuButton(
              controller.menuFieldItems,
              padding: EdgeInsets.zero,
              child: OutlinedButton.icon(
                onPressed: controller.attach,
                icon: const Icon(Iconsax.add_circle),
                label: const Text('Add Custom Field'),
              ),
            ),
          ),
        ),
      ),
      const Divider(),
      Text(
        'attachments'.tr,
        style: TextStyle(color: themeColor, fontSize: 12),
      ),
      const SizedBox(height: 5),
      Obx(
        () => Opacity(
          opacity: controller.editMode.value ? 1.0 : 0.6,
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              ...controller.attachmentChips,
            ],
          ),
        ),
      ),
      const Divider(),
      Obx(
        () => TagsInput(
          label: 'Tags',
          enabled: controller.editMode.value,
          controller: controller.tagsController,
        ),
      ),
      const Divider(),
      Theme(
          data: Get.theme.copyWith(disabledColor: Colors.grey),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: controller.groupId.value,
                  onChanged:
                      controller.reserved.value || !controller.editMode.value
                          ? null
                          : (value) => controller.groupId.value = value!,
                  decoration: const InputDecoration(labelText: 'Vault'),
                  items: [
                    ...GroupsController.to.combined
                        .map((e) => DropdownMenuItem<String>(
                              value: e.id,
                              child: Text(e.reservedName),
                            ))
                        .toList()
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => DropdownButtonFormField<HiveLisoCategory>(
                  isExpanded: true,
                  value: controller.categoryObject,
                  onChanged:
                      controller.reserved.value || !controller.editMode.value
                          ? null
                          : (value) => controller.category.value = value!.id,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    ...{
                      ...CategoriesController.to.combined,
                      controller.categoryObject
                    }
                        .map((e) => DropdownMenuItem<HiveLisoCategory>(
                              value: e,
                              child: Text(e.reservedName),
                            ))
                        .toList()
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ObxValue(
                (RxBool data) => CheckboxListTile(
                  title: Text('favorite'.tr),
                  value: data(),
                  onChanged: controller.editMode.value
                      ? (value) => data.value = value!
                      : null,
                  activeColor: Colors.pink,
                  contentPadding: EdgeInsets.zero,
                ),
                controller.favorite,
              ),
              ObxValue(
                (RxBool data) => CheckboxListTile(
                  title: Text('protected'.tr),
                  value: data(),
                  onChanged: controller.editMode.value
                      ? (value) => data.value = value!
                      : null,
                  contentPadding: EdgeInsets.zero,
                ),
                controller.protected,
              ),
              if (Persistence.to.canShare) ...[
                Text(
                  'shared_vaults'.tr,
                  style: TextStyle(color: themeColor, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Obx(
                  () => Opacity(
                    opacity: controller.editMode.value ? 1.0 : 0.6,
                    child: Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        ...controller.sharedVaultChips,
                      ],
                    ),
                  ),
                ),
                const Divider(),
              ],
            ],
          )),
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
      const SizedBox(height: 30),
    ];

    final appBar = AppBar(
      title: Text(controller.categoryObject.reservedName),
      leading: IconButton(
        onPressed: () async {
          if (await controller.canPop()) Get.back();
        },
        icon: Icon(
          Utils.isDrawerExpandable ? Iconsax.arrow_left_2 : LineIcons.times,
        ),
      ),
      actions: [
        Obx(
          () => Visibility(
            visible: controller.editMode.value,
            replacement: IconButton(
              onPressed: controller.editMode.toggle,
              icon: const Icon(LineIcons.pen),
            ),
            child: IconButton(
              onPressed: controller.joinedVaultItem
                  ? null
                  : mode == 'view'
                      ? controller.edit
                      : controller.add,
              icon: const Icon(LineIcons.check),
            ),
          ),
        ),
        if (mode == 'view') ...[
          ContextMenuButton(
            controller.menuItems,
            child: const Icon(LineIcons.verticalEllipsis),
          ),
        ],
        const SizedBox(width: 10),
      ],
    );

    final form = Form(
      key: controller.formKey,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        itemBuilder: (context, index) => items[index],
      ),
    );

    final content = controller.obx(
      (_) => form,
      onLoading: const BusyIndicator(),
    );

    return WillPopScope(
      onWillPop: controller.canPop,
      child: Scaffold(
        appBar: appBar,
        body: content,
      ),
    );
  }
}
