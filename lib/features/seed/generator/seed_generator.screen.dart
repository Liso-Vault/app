import 'package:app_core/globals.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/seed/seed_chips.widget.dart';

import '../../general/card_button.widget.dart';
import 'seed_generator_screen.controller.dart';

class SeedGeneratorScreen extends StatelessWidget with ConsoleMixin {
  const SeedGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SeedGeneratorScreenController());

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              'generated_seed_phrase'.tr.toUpperCase(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 30,
                bottom: 5,
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  Obx(() => SeedChips(seeds: controller.seed.split(' '))),
                  const SizedBox(height: 15),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CardButton(
                        text: 'Generate',
                        iconData: Iconsax.chart_outline,
                        onPressed: controller.generate,
                      ),
                      CardButton(
                        text: 'QR Code',
                        iconData: Iconsax.barcode_outline,
                        onPressed: () => AppUtils.showQR(
                          controller.seed.value,
                          title: 'Your Seed QR Code',
                          subTitle:
                              "Make sure you're in a safe location and free from prying eyes",
                        ),
                      ),
                      CardButton(
                        text: 'Copy',
                        iconData: Iconsax.copy_outline,
                        onPressed: () => Utils.copyToClipboard(
                          controller.seed.value,
                        ),
                      ),
                      if (controller.isFromDrawer) ...[
                        CardButton(
                          text: 'save'.tr,
                          iconData: Iconsax.add_circle_outline,
                          onPressed: controller.save,
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                Text(
                  '${'strength'.tr.toUpperCase()}: ',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Obx(
                  () => Text(
                    '${controller.strength.value} Bits',
                    style: const TextStyle(fontSize: 12),
                  ),
                )
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                ObxValue(
                  (RxInt data) => RadioListTile<int>(
                    title: const Text('24 Words'),
                    value: 256,
                    groupValue: controller.strength.value,
                    onChanged: (value) {
                      controller.strength.value = value!;
                      controller.generate();
                    },
                  ),
                  controller.strength,
                ),
                ObxValue(
                  (RxInt data) => RadioListTile<int>(
                    title: const Text('12 Words'),
                    value: 128,
                    groupValue: controller.strength.value,
                    onChanged: (value) {
                      controller.strength.value = value!;
                      controller.generate();
                    },
                  ),
                  controller.strength,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Some long text note to be added in this section. Maybe with some useful links to best practices and more...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );

    final appBar = AppBar(
      title: const Text('Seed Generator'),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
      actions: [
        if (gParameters['return'] != null) ...[
          IconButton(
            onPressed: () => Get.backLegacy(result: controller.seed.value),
            icon: const Icon(Icons.check),
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
