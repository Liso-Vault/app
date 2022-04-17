import 'package:chips_input/chips_input.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/menu/menu.button.dart';

import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import '../general/remote_image.widget.dart';
import 'item_screen.controller.dart';

class ItemScreen extends GetWidget<ItemScreenController> with ConsoleMixin {
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
      initialValue: controller.tags,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'tags'.tr,
      ),
      findSuggestions: controller.querySuggestions,
      onChanged: (data) => controller.tags = data,
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
      // Text(
      //   category.tr,
      //   style: const TextStyle(fontSize: 30),
      // ),
      // const SizedBox(height: 15),
      // const Text(
      //   'Make sure you are alone in a safe room',
      //   style: TextStyle(color: Colors.grey),
      // ),
      // const SizedBox(height: 15),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ICON
          Obx(
            () => ContextMenuButton(
              controller.menuItemsChangeIcon,
              child: controller.iconUrl().isEmpty
                  ? const Icon(Icons.photo, size: 30)
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
                labelText: 'title'.tr + ' *',
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      // -------- RENDER FIELDS AS WIDGETS -------- //
      Obx(() => Column(children: [...controller.widgets])),
      // -------- RENDER FIELDS AS WIDGETS -------- //
      const SizedBox(height: 10),
      // TAGS
      tagsInput,
      const SizedBox(height: 10),
      ObxValue(
        (RxBool data) => SwitchListTile(
          title: Text('favorite'.tr),
          value: data(),
          onChanged: data,
          activeColor: Colors.pink,
          secondary: data()
              ? const FaIcon(FontAwesomeIcons.solidHeart)
              : const FaIcon(FontAwesomeIcons.heart),
        ),
        controller.favorite,
      ),
      ObxValue(
        (RxBool data) => SwitchListTile(
          title: Text('protected'.tr),
          value: data(),
          onChanged: data,
          secondary: data()
              ? const FaIcon(FontAwesomeIcons.shield)
              : const FaIcon(FontAwesomeIcons.shieldHalved),
        ),
        controller.protected,
      ),
      if (mode == 'update') ...[
        const Divider(),
        Text(
          'Last modified ${controller.item?.updatedDateTimeFormatted}',
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
      centerTitle: false,
      title: Text(category.tr),
      leading: const AppBarLeadingButton(),
      actions: [
        IconButton(
          onPressed: mode == 'update' ? controller.edit : controller.add,
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
        itemCount: items.length,
        shrinkWrap: true,
        itemBuilder: (context, index) => items[index],
        padding: const EdgeInsets.all(15),
      ),
    );

    final content = controller.obx(
      (_) => form,
      onLoading: const BusyIndicator(),
    );

    return Scaffold(
      appBar: appBar,
      body: content,
    );
  }
}
