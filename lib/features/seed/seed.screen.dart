import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
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
          const SizedBox(height: 35),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: controller.passphraseCard!),
              IconButton(
                icon: const Icon(LineIcons.verticalEllipsis),
                onPressed: controller.showSeedOptions,
              )
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller.addressController,
            decoration: Styles.inputDecoration.copyWith(
              labelText: 'Address',
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller.descriptionController,
            minLines: 1,
            maxLines: 4,
            decoration: Styles.inputDecoration.copyWith(
              labelText: 'Description',
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
          const Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            style: TextStyle(color: Colors.grey),
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
                const SizedBox(width: 20),
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
