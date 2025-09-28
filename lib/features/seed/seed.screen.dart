import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:blur/blur.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:liso/features/seed/seed_chips.widget.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../core/persistence/persistence.dart';
import '../../core/utils/globals.dart';
import '../menu/menu.button.dart';
import 'seed_screen.controller.dart';

class SeedScreen extends StatelessWidget with ConsoleMixin {
  const SeedScreen({super.key});

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
                icon: const Icon(Iconsax.eye_outline),
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
        Icon(Iconsax.key_square_outline, size: 150, color: themeColor),
        const SizedBox(height: 20),
        Text(
          'master_seed_phrase'.tr,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "master_seed_phrase_desc".tr,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        seedPhrase,
        const SizedBox(height: 20),
        if (!AppPersistence.to.backedUpSeed.val ||
            !WalletService.to.isSaved) ...[
          ObxValue(
            (RxBool data) => CheckboxListTile(
              checkboxShape: const CircleBorder(),
              title: Text("i_have_backed_up_my_seed_in_a_safe_location".tr),
              value: data(),
              onChanged: data.call,
            ),
            controller.chkBackedUpSeed,
          ),
          const Divider(height: 0, color: Colors.grey, thickness: 0.1),
          ObxValue(
            (RxBool data) => CheckboxListTile(
              checkboxShape: const CircleBorder(),
              title: Text("i_have_written_down_my_seed".tr),
              value: data(),
              onChanged: data.call,
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
                icon: const Icon(Iconsax.arrow_circle_right_outline),
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
            child: const Icon(LineAwesome.ellipsis_v_solid),
          ),
          TextButton(
            onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
            child: Text('need_help'.tr),
          ),
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
