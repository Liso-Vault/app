import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/general/custom_chip.widget.dart';

import '../../core/utils/globals.dart';
import 'mnemonic_screen.controller.dart';

class MnemonicScreen extends GetView<MnemonicScreenController>
    with ConsoleMixin {
  const MnemonicScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mnemonicPhrase = GestureDetector(
      onLongPress: controller.options,
      onSecondaryTap: controller.options, // mouse right click
      // child: Text(
      //   controller.mnemonic.value,
      //   textAlign: TextAlign.center,
      //   style: TextStyle(fontSize: GetPlatform.isMobile ? 20 : 25),
      // ),
      child: Wrap(
        spacing: 5,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: controller.mnemonic.value
            .split(' ')
            .map(
              (e) => CustomChip(
                color: Colors.green.shade800,
                label: Text(e, style: const TextStyle(fontSize: 18)),
              ),
            )
            .toList(),
      ),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(LineIcons.key, size: 100, color: kAppColor),
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
        const SizedBox(height: 15),
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
                      blur: 5.0,
                      blurColor: Colors.grey.shade900,
                      child: mnemonicPhrase,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LineIcons.eye),
                    onPressed: () =>
                        controller.passphraseIndexedStack.value = 1,
                  ),
                ],
              ),
              mnemonicPhrase,
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Divider(),
        ObxValue(
          (RxBool data) => CheckboxListTile(
            title: const Text(
                "I have backed up my seed in a safe location"), //    <-- label
            value: data.value,
            onChanged: data,
          ),
          controller.chkBackedUpSeed,
        ),
        ObxValue(
          (RxBool data) => CheckboxListTile(
            title: const Text("I have written down my seed"), //    <-- label
            value: data.value,
            onChanged: data,
          ),
          controller.chkWrittenSeed,
        ),
        const SizedBox(height: 20),
        Obx(
          () => TextButton.icon(
            onPressed:
                controller.canProceed ? controller.continuePressed : null,
            label: Text('continue'.tr),
            icon: const Icon(LineIcons.arrowRight),
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
