import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/styles.dart';

import '../general/busy_indicator.widget.dart';
import 'item_screen.controller.dart';

class ItemScreen extends GetView<ItemScreenController> {
  const ItemScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mode = Get.parameters['mode'].toString();
    final category = Get.parameters['category'].toString();

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
          IconButton(
            icon: const Icon(Icons.photo, size: 30),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
          // TITLE
          Expanded(
            child: TextFormField(
              controller: controller.titleController,
              decoration: Styles.inputDecoration.copyWith(
                labelText: 'Title',
              ),
            ),
          ),
        ],
      ),
      const Divider(),
      // -------- RENDER FIELDS AS WIDGETS -------- //
      Obx(() => Column(children: [...controller.widgets])),
      // -------- RENDER FIELDS AS WIDGETS -------- //
      const Divider(),
      // TAGS
      TextFormField(
        controller: controller.tagsController,
        decoration: Styles.inputDecoration.copyWith(
          labelText: 'Tags',
        ),
      ),
      if (mode == 'update') ...[
        const SizedBox(height: 10),
        ObxValue(
          (RxBool data) => SwitchListTile(
            title: Text('favorite'.tr),
            value: data.value,
            onChanged: data,
          ),
          controller.favorite,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.edit,
                label: const Text('Update'),
                icon: const Icon(LineIcons.check),
                style: Styles.elevatedButtonStyle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.delete,
                label: const Text('Delete'),
                icon: const Icon(LineIcons.trash),
                style: Styles.elevatedButtonStyleNegative,
              ),
            )
          ],
        ),
      ] else if (mode == 'add') ...[
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: controller.add,
          label: const Text('Add'),
          icon: const Icon(LineIcons.plus),
          style: Styles.elevatedButtonStyle,
        )
      ],
      if (mode == 'update') ...[
        const SizedBox(height: 20),
        // TODO: better datetime format
        Text(
          'Last updated ${controller.item?.metadata.updatedTime}', // TODO: better DateTime format
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
    );

    return Scaffold(
      appBar: appBar,
      body: content,
    );
  }
}
