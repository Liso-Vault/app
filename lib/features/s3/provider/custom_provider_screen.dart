import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/features/general/appbar_leading.widget.dart';
import 'package:liso/features/general/section.widget.dart';
import 'package:liso/features/s3/provider/custom_provider_screen.controller.dart';

import '../../../core/persistence/persistence_builder.widget.dart';
import '../../../core/utils/globals.dart';

class CustomSyncProviderScreen
    extends GetView<CustomSyncProviderScreenController> with ConsoleMixin {
  const CustomSyncProviderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: controller.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Section(
              text: 'S3 Configuration',
              fontSize: 15,
            ),
            TextFormField(
              controller: controller.endpointController,
              validator: (data) => data!.isNotEmpty ? null : 'required'.tr,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Endpoint',
                hintText: 's3.filebase.com',
              ),
            ),
            TextFormField(
              controller: controller.accessKeyController,
              validator: (data) => data!.isNotEmpty ? null : 'required'.tr,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Access Key',
              ),
            ),
            TextFormField(
              controller: controller.secretKeyController,
              validator: (data) => data!.isNotEmpty ? null : 'required'.tr,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Secret Key',
              ),
            ),
            TextFormField(
              controller: controller.bucketController,
              validator: (data) => data!.isNotEmpty ? null : 'required'.tr,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Bucket',
              ),
            ),
            TextFormField(
              controller: controller.portController,
              // TODO: validator
              inputFormatters: [
                inputFormatterRestrictSpaces,
                inputFormatterNumericOnly,
              ],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: '8080',
              ),
            ),
            TextFormField(
              controller: controller.regionController,
              // TODO: validator
              decoration: const InputDecoration(
                labelText: 'Region',
              ),
            ),
            TextFormField(
              controller: controller.sessionTokenController,
              // TODO: validator
              decoration: const InputDecoration(
                labelText: 'Session Token',
              ),
            ),
            PersistenceBuilder(
              builder: (p, context) => SwitchListTile(
                title: const Text('Enable Trace'),
                value: Persistence.to.s3EnableTrace.val,
                onChanged: (value) => Persistence.to.s3EnableTrace.val = value,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const Divider(),
            PersistenceBuilder(
              builder: (p, context) => SwitchListTile(
                title: const Text('Use SSL'),
                value: Persistence.to.s3UseSsl.val,
                onChanged: (value) => Persistence.to.s3UseSsl.val = value,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );

    final actions = [
      Obx(
        () => controller.busy.value
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            : TextButton.icon(
                onPressed: controller.testConnection,
                icon: const Icon(LineIcons.check),
                label: const Text('Test'),
              ),
      ),
      const SizedBox(width: 5),
    ];

    final appBar = AppBar(
      title: const Text('Custom Provider'),
      leading: const AppBarLeadingButton(),
      actions: actions,
    );

    return Scaffold(
      appBar: appBar,
      body: content,
    );
  }
}
