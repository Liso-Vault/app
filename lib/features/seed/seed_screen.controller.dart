import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:liso/features/seed/seed_field.widget.dart';

import '../../core/hive/hive_items.service.dart';
import '../../core/utils/ui_utils.dart';
import '../menu/menu.item.dart';

class SeedScreenController extends GetxController with ConsoleMixin {
  // VARIABLES'

  List<ContextMenuItem> get menuItems => [
        if (!isDisplayMode) ...[
          ContextMenuItem(
            title: 'Generate',
            leading: const Icon(Iconsax.chart),
            onSelected: _generate,
          ),
          ContextMenuItem(
            title: 'Custom',
            leading: const Icon(Iconsax.key),
            onSelected: _custom,
          ),
        ],
        ContextMenuItem(
          title: 'QR Code',
          leading: const Icon(Iconsax.barcode),
          onSelected: _showQR,
        ),
        ContextMenuItem(
          title: 'Copy',
          leading: const Icon(Iconsax.copy),
          onSelected: () => Utils.copyToClipboard(seed.value),
        ),
      ];

  // PROPERTIES
  final seed = ''.obs;
  final chkBackedUpSeed = false.obs;
  final chkWrittenSeed = false.obs;
  final passphraseIndexedStack = 0.obs;
  final isDisplayMode = Get.parameters['mode'] == 'display';

  // GETTERS
  bool get canProceed => chkBackedUpSeed.value && chkWrittenSeed.value;

  // INIT
  @override
  void onInit() {
    seed.value = bip39.generateMnemonic(strength: 256);
    super.onInit();
  }

  @override
  void onReady() async {
    if (isDisplayMode) {
      final result = await HiveItemsService.to.obtainFieldValue(
        itemId: 'seed',
        fieldId: 'seed',
      );

      if (result.isLeft) {
        return UIUtils.showSimpleDialog(
          'Seed Not Found',
          'Cannot find your saved seed',
        );
      }

      seed.value = result.right;
    }

    super.onReady();
  }

  // FUNCTIONS

  void continuePressed() async {
    if (!isDisplayMode) {
      Utils.adaptiveRouteOpen(
        name: Routes.createPassword,
        parameters: {
          'seed': seed.value,
          'from': 'seed_screen',
        },
      );
    } else {
      // display mode
      Persistence.to.backedUpSeed.val = true;
      Get.back();
    }
  }

  void _showQR() {
    UIUtils.showQR(
      seed.value,
      title: 'Seed QR Code',
      subTitle: "Make sure you're in a safe location and free from prying eyes",
    );
  }

  void _generate() async {
    final seed_ = await Utils.adaptiveRouteOpen(
      name: Routes.seedGenerator,
      parameters: {'return': 'true'},
    );

    if (seed_ == null) return;
    seed.value = seed_;
  }

  void _custom() {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();

    void _use() {
      if (!formKey.currentState!.validate()) return;
      seed.value = controller.text;
      Get.back();
    }

    final dialogContent = Form(
      key: formKey,
      child: SeedField(
        fieldController: controller,
        onFieldSubmitted: (text) => _use(),
        showGenerate: false,
      ),
    );

    Get.dialog(AlertDialog(
      title: const Text('Enter Your Seed'),
      content: Utils.isDrawerExpandable
          ? dialogContent
          : SizedBox(
              width: 450,
              child: dialogContent,
            ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: _use,
          child: Text('use'.tr),
        ),
      ],
    ));
  }
}
