import 'package:chips_input/chips_input.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/styles.dart';

import '../general/busy_indicator.widget.dart';
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
      initialValue: controller.tags,
      textCapitalization: TextCapitalization.words,
      decoration: Styles.inputDecoration.copyWith(
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
            () => IconButton(
              icon: controller.icon.value.isEmpty
                  ? const Icon(Icons.photo, size: 30)
                  : Image.memory(controller.icon.value),
              onPressed: controller.changeIcon,
            ),
          ),
          const SizedBox(width: 10),
          // TITLE
          Expanded(
            child: TextFormField(
              controller: controller.titleController,
              textCapitalization: TextCapitalization.words,
              validator: (data) => data!.isNotEmpty ? null : 'required'.tr,
              decoration: Styles.inputDecoration.copyWith(
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
          value: data.value,
          onChanged: data,
          activeColor: Colors.pink,
          secondary: data.value
              ? const FaIcon(FontAwesomeIcons.solidHeart, color: Colors.pink)
              : const FaIcon(FontAwesomeIcons.heart),
        ),
        controller.favorite,
      ),
      ObxValue(
        (RxBool data) => SwitchListTile(
          title: Text('protected'.tr),
          value: data.value,
          onChanged: data,
          activeColor: kAppColor,
          secondary: data.value
              ? const FaIcon(FontAwesomeIcons.shield, color: kAppColor)
              : const FaIcon(FontAwesomeIcons.shieldHalved),
        ),
        controller.protected,
      ),
      if (mode == 'update') ...[
        const Divider(),
        // TODO: better datetime format
        Text(
          'Last updated ${controller.item?.updatedDateTimeFormatted}', // TODO: better DateTime format
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
      const SizedBox(height: 30),
    ];

    final form = Form(
      key: controller.formKey,
      child: ListView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        itemBuilder: (context, index) => items[index],
        padding: const EdgeInsets.all(10),
      ),
    );

    final content = controller.obx(
      (_) => Padding(
        padding: const EdgeInsets.all(15),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: Styles.containerConstraints,
            child: form,
          ),
        ),
      ),
      onLoading: const BusyIndicator(),
    );

    final appBar = AppBar(
      title: Text(category.tr),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: mode == 'update' ? controller.edit : controller.add,
          icon: const Icon(LineIcons.check),
        ),
        if (mode == 'update') ...[
          IconButton(
            icon: const Icon(LineIcons.verticalEllipsis),
            onPressed: controller.menu,
          ),
        ],
        const SizedBox(width: 10),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: content,
    );
  }
}
