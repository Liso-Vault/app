import 'package:blur/blur.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/features/seed/seed_chips.widget.dart';

import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../general/appbar_leading.widget.dart';
import '../menu/menu.button.dart';
import 'seed_screen.controller.dart';

class SeedScreen extends StatelessWidget with ConsoleMixin {
  const SeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SeedScreenController());

    final phraseChips = GestureDetector(
      onLongPress: () => Utils.copyToClipboard(controller.seed.value),
      onSecondaryTap: () => Utils.copyToClipboard(controller.seed.value),
      child: Obx(() => SeedChips(seeds: controller.seed.value.split(' '))),
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
        const SizedBox(height: 5),
        const Text(
          "Please carefully write down your seed and store it in a safe location",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        seedPhrase,
        const SizedBox(height: 20),
        if (!Persistence.to.backedUpSeed.val) ...[
          ObxValue(
            (RxBool data) => CheckboxListTile(
              title: const Text("I have backed up my seed in a safe location"),
              value: data(),
              onChanged: data,
            ),
            controller.chkBackedUpSeed,
          ),
          ObxValue(
            (RxBool data) => CheckboxListTile(
              title: const Text("I have written down my seed"),
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
        ]
      ],
    );

    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLeadingButton(),
        actions: [
          ContextMenuButton(
            controller.menuItems,
            child: const Icon(LineIcons.verticalEllipsis),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: content,
        ),
      ),
    );
  }
}
