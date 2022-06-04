import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/persistence/persistence_builder.widget.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/general/busy_indicator.widget.dart';
import 'package:liso/features/general/passphrase.card.dart';
import 'package:liso/features/s3/s3.service.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../general/custom_choice_chip.widget.dart';
import '../general/segmented_item.widget.dart';
import 'import_screen.controller.dart';

class ImportScreen extends GetView<ImportScreenController> with ConsoleMixin {
  const ImportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final persistence = Get.find<Persistence>();

    // TODO: reuse from configuration screen
    final syncOptions = PersistenceBuilder(
      builder: (p, context) {
        final isSia = persistence.syncProvider.val == LisoSyncProvider.sia.name;
        final isIPFS =
            persistence.syncProvider.val == LisoSyncProvider.ipfs.name;
        final isStorj =
            persistence.syncProvider.val == LisoSyncProvider.storj.name;
        final isSkyNet =
            persistence.syncProvider.val == LisoSyncProvider.skynet.name;
        final isCustom =
            persistence.syncProvider.val == LisoSyncProvider.custom.name;

        return Wrap(
          spacing: 5,
          children: [
            CustomChoiceChip(
              label: 'Sia',
              selected: isSia,
              onSelected: (value) {
                persistence.syncProvider.val = LisoSyncProvider.sia.name;
                S3Service.to.init();
              },
            ),
            CustomChoiceChip(
              label: 'Storj',
              selected: isStorj,
              onSelected: (value) {
                persistence.syncProvider.val = LisoSyncProvider.storj.name;
                S3Service.to.init();
              },
            ),
            CustomChoiceChip(
              label: 'IPFS',
              selected: isIPFS,
              onSelected: (value) {
                persistence.syncProvider.val = LisoSyncProvider.ipfs.name;
                S3Service.to.init();
              },
            ),
            CustomChoiceChip(
              label: 'SkyNet',
              selected: isSkyNet,
              onSelected: (value) {
                persistence.syncProvider.val = LisoSyncProvider.skynet.name;
                S3Service.to.init();
              },
            ),
            CustomChoiceChip(
              label: 'Custom',
              selected: isCustom,
              onSelected: (value) {
                Utils.adaptiveRouteOpen(
                  name: Routes.syncProvider,
                  parameters: {'from': 'import'},
                );
              },
            ),
          ],
        );
      },
    );

    final content = Form(
      key: controller.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.import_1, size: 100, color: themeColor),
          const SizedBox(height: 20),
          Text(
            'import_vault'.tr,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          const Text(
            "Import your vault and enter your master seed phrase to decrypt it.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Obx(
            () => CupertinoSegmentedControl<ImportMode>(
              groupValue: controller.importMode.value,
              onValueChanged: (value) => controller.importMode.value = value,
              children: {
                ImportMode.liso: SegmentedControlItem(
                  text: '${ConfigService.to.appName} Cloud',
                  iconData: Iconsax.cloud,
                ),
                ImportMode.file: const SegmentedControlItem(
                  text: 'Liso File',
                  iconData: Iconsax.document_code,
                ),
              },
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (controller.importMode() == ImportMode.file) {
              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller.filePathController,
                      validator: (text) =>
                          text!.isEmpty ? 'Import your vault file' : null,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        hintText: 'Path to your <vault>.$kVaultExtension file',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.import_1),
                    onPressed: controller.importFile,
                  ),
                ],
              );
            } else if (controller.importMode() == ImportMode.liso) {
              return Column(
                children: [
                  const Text('Select your provider'),
                  const SizedBox(height: 10),
                  syncOptions,
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
          const SizedBox(height: 20),
          PassphraseCard(
            fieldController: controller.seedController,
            onFieldSubmitted: (text) => controller.continuePressed,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: controller.continuePressed,
              label: Text('continue'.tr),
              icon: const Icon(Iconsax.arrow_circle_right),
            ),
          ),
        ],
      ),
    );

    final scaffold = Scaffold(
      appBar: AppBar(centerTitle: false),
      body: Center(
        child: Container(
          constraints: Styles.containerConstraints,
          padding: const EdgeInsets.all(20),
          child: controller.obx(
            (_) => SingleChildScrollView(child: content),
            onLoading: const BusyIndicator(),
          ),
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () => controller.canPop,
      child: scaffold,
    );
  }
}
