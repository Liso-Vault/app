import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/styles.dart';

import 'seed_screen.controller.dart';

class SeedScreen extends GetView<SeedScreenController> {
  const SeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mode = Get.parameters['mode'].toString();
    final title = '${GetUtils.capitalizeFirst(mode)} Seed';

    final form = Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 30),
          ),
          const SizedBox(height: 15),
          const Text(
            'Make sure you are alone in a safe room',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 35),
          Obx(
            () => IndexedStack(
              index: controller.passphraseIndexedStack(),
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Blur(
                        blur: 2.5,
                        blurColor: Colors.grey.shade900,
                        child: controller.passphraseCard!,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LineIcons.eye),
                      onPressed: () =>
                          controller.passphraseIndexedStack.value = 1,
                    ),
                  ],
                ),
                controller.passphraseCard!,
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: controller.addressController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            minLines: 1,
            maxLines: 2,
            maxLength: 60,
            validator: (text) => text!.isEmpty ? 'Address is required' : null,
            decoration: Styles.inputDecoration.copyWith(
              labelText: 'Address',
              counterText: '',
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: controller.descriptionController,
            minLines: 1,
            maxLines: 4,
            maxLength: 300,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (text) =>
                text!.isEmpty ? 'Description is required' : null,
            decoration: Styles.inputDecoration.copyWith(
              labelText: 'Description',
              counterText: '',
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedOrigin.value,
              onChanged: controller.changedOriginItem,
              items: controller.originDropdownItems,
              decoration: Styles.inputDecoration.copyWith(
                labelText: 'Origin',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => DropdownButtonFormField<String>(
              value: controller.selectedLedger.value,
              onChanged: controller.changedLedgerItem,
              items: controller.ledgerDropdownItems,
              decoration: Styles.inputDecoration.copyWith(
                labelText: 'Distributed Ledger Technology',
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (mode == 'update') ...[
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
            ElevatedButton.icon(
              onPressed: controller.add,
              label: const Text('Add'),
              icon: const Icon(LineIcons.plus),
              style: Styles.elevatedButtonStyle,
            )
          ],
          if (mode == 'update') ...[
            const SizedBox(height: 20),
            Text(
              'Last updated ${controller.object!.metadata.updatedTime}',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 30),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Container(
            constraints: Styles.containerConstraints,
            child: SingleChildScrollView(
              child: form,
            ),
          ),
        ),
      ),
    );
  }
}
