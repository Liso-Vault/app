import 'package:app_core/config/app.model.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:app_core/widgets/busy_indicator.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:liso/core/hive/models/group.hive.dart';
import 'package:liso/features/general/widget_refresher.widget.dart';
import 'package:liso/features/groups/groups.controller.dart';

import '../../core/utils/globals.dart';
import '../../core/utils/styles.dart';
import '../app/routes.dart';
import 'import_screen.controller.dart';

class ImportScreen extends StatelessWidget with ConsoleMixin {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImportScreenController());

    final content = Container(
      constraints: Styles.containerConstraints,
      child: Form(
        key: controller.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.import_1_outline, size: 100, color: themeColor),
            const SizedBox(height: 20),
            const Text(
              'Import Items',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 5),
            Text(
              "Import items from external sources to ${appConfig.name}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Obx(
              () {
                final dropdownRefresher = Get.put(WidgetRefresherController());

                return WidgetRefresher(
                  controller: dropdownRefresher,
                  child: DropdownButtonFormField<String>(
                    value: controller.destinationGroupId.value,
                    decoration: const InputDecoration(
                      labelText: 'Destination Vault',
                    ),
                    onChanged: (value) async {
                      if (value == 'new-vault') {
                        controller.destinationGroupId.value =
                            GroupsController.to.reserved.first.id;
                        // hack to refresh dropdown text
                        dropdownRefresher.reload();

                        return await Utils.adaptiveRouteOpen(
                          name: AppRoutes.vaults,
                        );
                      }

                      controller.destinationGroupId.value = value!;
                    },
                    items: {
                      ...GroupsController.to.combined,
                      HiveLisoGroup(
                        id: kSmartGroupId,
                        name: 'Smart - assign/create automatically',
                        metadata: null,
                      ),
                      HiveLisoGroup(
                        id: 'new-vault',
                        name: 'New Vault',
                        metadata: null,
                      ),
                    }
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.id,
                            child: Text(e.reservedName),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Obx(
              () => DropdownButtonFormField<ExportedSourceFormat>(
                value: controller.sourceFormat.value,
                onChanged: (value) => controller.sourceFormat.value = value!,
                decoration: const InputDecoration(labelText: 'Source & Format'),
                items: sourceFormats
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.title),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.filePathController,
                    validator: (text) => text!.isEmpty
                        ? 'Choose the exported file to import'
                        : null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      hintText: 'Path to your exported file',
                      label: Text('Exported File Path'),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.import_1_outline),
                  onPressed: controller.importFile,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Obx(
              () => CheckboxListTile(
                title: Text(
                  'Automatically tag items with (${controller.sourceFormat.value.id})',
                ),
                value: controller.autoTag.value,
                onChanged: (value) => controller.autoTag.value = value!,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: controller.continuePressed,
              label: Text('continue'.tr),
              icon: const Icon(Iconsax.arrow_circle_right_outline),
            ),
          ],
        ),
      ),
    );

    final scaffold = Scaffold(
      appBar: AppBar(
        leading: Obx(
          () => Visibility(
            visible: !controller.busy.value,
            child: const AppBarLeadingButton(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
            child: const Text('Need Help ?'),
          ),
        ],
      ),
      body: controller.obx(
        (_) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: content,
          ),
        ),
        onLoading: const BusyIndicator(),
      ),
    );

    // allow closing of screen
    if (kDebugMode) return scaffold;

    return WillPopScope(
      onWillPop: () => controller.canPop,
      child: scaffold,
    );
  }
}
