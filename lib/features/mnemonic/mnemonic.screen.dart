import 'package:blur/blur.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/general/custom_chip.widget.dart';

import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../general/passphrase.card.dart';
import '../general/segmented_item.widget.dart';
import 'mnemonic_screen.controller.dart';

class MnemonicScreen extends GetView<MnemonicScreenController>
    with ConsoleMixin {
  const MnemonicScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final phraseChips = GestureDetector(
      onTap: controller.generate,
      onLongPress: () => Utils.copyToClipboard(controller.mnemonic.value),
      onSecondaryTap: () => Utils.copyToClipboard(controller.mnemonic.value),
      child: Obx(
        () => Wrap(
          spacing: GetPlatform.isMobile ? 1 : 5,
          runSpacing: GetPlatform.isMobile ? 5 : 10,
          alignment: WrapAlignment.center,
          children: controller.mnemonic.value
              .split(' ')
              .asMap()
              .entries
              .map(
                (e) => CustomChip(
                  label: Text(
                    '${e.key + 1}. ${e.value}',
                    style: TextStyle(
                      fontSize: GetPlatform.isMobile ? null : 17,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );

    final seedPhrase = Obx(
      () => IndexedStack(
        index: controller.passphraseIndexedStack(),
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Blur(
                  blur: 5.0,
                  blurColor: Colors.grey.shade900,
                  child: phraseChips,
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.eye),
                onPressed: () => controller.passphraseIndexedStack.value = 1,
              ),
            ],
          ),
          phraseChips,
        ],
      ),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Iconsax.key_square, size: 100, color: themeColor),
        const SizedBox(height: 20),
        const Text(
          'Master Seed Phrase',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 15),
        const Text(
          "Please carefully write down your seed and export it to a safe location",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Obx(
          () => CupertinoSegmentedControl<MnemonicMode>(
            groupValue: controller.mode.value,
            onValueChanged: (value) => controller.mode.value = value,
            children: {
              MnemonicMode.generate: SegmentedControlItem(
                text: 'generate'.tr,
                iconData: Iconsax.chart_3,
              ),
              MnemonicMode.restore: SegmentedControlItem(
                text: 'existing'.tr,
                iconData: Iconsax.import,
              ),
            },
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => Visibility(
            visible: controller.mode.value == MnemonicMode.generate,
            replacement: Form(
              key: controller.formKey,
              child: PassphraseCard(
                controller: controller.seedController,
                onFieldSubmitted: (text) => controller.continuePressed,
              ),
            ),
            child: seedPhrase,
          ),
        ),
        const SizedBox(height: 20),
        ObxValue(
          (RxBool data) => CheckboxListTile(
            title: const Text(
                "I have backed up my seed in a safe location"), //    <-- label
            value: data(),
            onChanged: data,
          ),
          controller.chkBackedUpSeed,
        ),
        ObxValue(
          (RxBool data) => CheckboxListTile(
            title: const Text("I have written down my seed"), //    <-- label
            value: data(),
            onChanged: data,
          ),
          controller.chkWrittenSeed,
        ),
        const SizedBox(height: 20),
        Obx(
          () => SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed:
                  controller.canProceed ? controller.continuePressed : null,
              label: Text('continue'.tr),
              icon: const Icon(Iconsax.arrow_circle_right),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: Styles.containerConstraints,
            child: SingleChildScrollView(child: content),
          ),
        ),
      ),
    );
  }
}
