import 'package:chips_input/chips_input.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/features/general/section.widget.dart';
import 'package:liso/features/menu/menu.button.dart';

import '../../core/hive/hive_groups.service.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../general/busy_indicator.widget.dart';
import '../general/remote_image.widget.dart';
import 'item_screen.controller.dart';

class ItemScreen extends GetView<ItemScreenController> with ConsoleMixin {
  const ItemScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mode = Get.parameters['mode'].toString();
    final category = Get.parameters['category'].toString();
    final chipsKey = GlobalKey<ChipsInputState>();

    final tagsInput = ChipsInput<String>(
      key: chipsKey,
      controller: controller.tagsController,
      maxChips: 5,
      initialValue: controller.tags.toList(),
      textCapitalization: TextCapitalization.words,
      maxLength: 40,
      decoration: InputDecoration(labelText: 'tags'.tr),
      findSuggestions: controller.querySuggestions,
      onChanged: (data) => controller.tags = data.toSet(),
      readOnly: controller.joinedVaultItem,
      // onEditingComplete: controller.querySubmitted,
      // onEditingComplete: () async {
      //   console.info('completed: ${controller.tagsController.text}');
      //   // chipsKey.currentState!.addChip(controller.tagsController.text);
      //   final options = await chipsKey.currentState!.widget.findSuggestions(
      //       controller.tagsController.text.replaceAll(" ", ""));

      //   console.info('first: ${options.first}');
      //   chipsKey.currentState!.addChip(options.first);
      //   console.info('completed: ${controller.tagsController.text}');
      // },
      chipBuilder: (context, state, tag) {
        return InputChip(
          key: ObjectKey(tag),
          label: Text(tag),
          onDeleted: () => state.deleteChip(tag),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      },
      suggestionBuilder: (context, tag) {
        return ListTile(
          key: ObjectKey(tag),
          title: Text(tag.toString()),
          subtitle: Text(tag.toString()),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Material(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (context, index) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final tag = options.elementAt(index);

              return ListTile(
                key: ObjectKey(tag),
                title: Text(tag),
                onTap: () => onSelected(tag),
              );
            },
          ),
        );
      },
    );

    final items = [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ICON
          Obx(
            () => ContextMenuButton(
              controller.menuItemsChangeIcon,
              enabled: !controller.joinedVaultItem,
              child: controller.iconUrl().isEmpty
                  ? Utils.categoryIcon(
                      LisoItemCategory.values.byName(controller.item.category),
                    )
                  : RemoteImage(
                      url: controller.iconUrl(),
                      width: 30,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          // TITLE
          Expanded(
            child: TextFormField(
              autofocus: mode == 'add',
              controller: controller.titleController,
              textCapitalization: TextCapitalization.words,
              validator: (data) => data!.isNotEmpty ? null : 'required'.tr,
              decoration: InputDecoration(
                labelText: '${'title'.tr} *',
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      // -------- RENDER FIELDS AS WIDGETS -------- //
      Obx(
        () => ListView.separated(
          shrinkWrap: true,
          itemCount: controller.widgets.length,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, index) => const SizedBox(height: 10),
          itemBuilder: (_, index) => controller.widgets[index],
        ),
      ),
      // -------- RENDER FIELDS AS WIDGETS -------- //
      const SizedBox(height: 10),
      tagsInput, // TAGS
      const SizedBox(height: 10),
      ListTile(
        title: Obx(() => Text('${controller.attachments.length} Attachments')),
        trailing: Icon(Iconsax.attach_circle, color: themeColor),
        contentPadding: EdgeInsets.zero,
        onTap: controller.attach,
        enabled: !controller.joinedVaultItem,
      ),
      const Divider(),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(
        isExpanded: true,
        value: controller.groupId.value,
        onChanged: (value) => controller.groupId.value = value!,
        decoration: const InputDecoration(labelText: 'Vault'),
        items: [
          ...HiveGroupsService.to.data
              .map((e) => DropdownMenuItem<String>(
                    value: e.id,
                    child: Text(e.reservedName),
                  ))
              .toList()
        ],
      ),
      const SizedBox(height: 10),
      ObxValue(
        (RxBool data) => CheckboxListTile(
          title: Text('favorite'.tr),
          value: data(),
          onChanged: data,
          activeColor: Colors.pink,
          contentPadding: EdgeInsets.zero,
        ),
        controller.favorite,
      ),
      const Divider(),
      ObxValue(
        (RxBool data) => CheckboxListTile(
          title: Text('protected'.tr),
          value: data(),
          onChanged: data,
          contentPadding: EdgeInsets.zero,
        ),
        controller.protected,
      ),
      if (controller.sharedVaultChips.isNotEmpty &&
          Persistence.to.canShare) ...[
        const Divider(),
        Section(text: 'shared_vaults'.tr.toUpperCase()),
        Obx(
          () => Wrap(
            spacing: 5,
            children: [
              ...controller.sharedVaultChips,
            ],
          ),
        ),
      ],
      if (mode == 'update') ...[
        const Divider(),
        const SizedBox(height: 20),
        Text(
          'Modified ${controller.item.updatedDateTimeFormatted}',
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          'Created ${controller.item.createdDateTimeFormatted}',
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
      const SizedBox(height: 30),
    ];

    final appBar = AppBar(
      centerTitle: false,
      title: Text(category.tr),
      leading: IconButton(
        onPressed: () async {
          final canPop = await controller.canPop();
          if (canPop) Get.back();
        },
        icon: Icon(
          Utils.isDrawerExpandable ? Iconsax.arrow_left_2 : LineIcons.times,
        ),
      ),
      actions: [
        IconButton(
          onPressed: controller.joinedVaultItem
              ? null
              : mode == 'update'
                  ? controller.edit
                  : controller.add,
          icon: const Icon(LineIcons.check),
        ),
        if (mode == 'update') ...[
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
        padding: const EdgeInsets.all(30),
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
