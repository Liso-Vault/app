import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:liso/features/attachments/attachment.tile.dart';

import '../files/storage.service.dart';
import '../general/centered_placeholder.widget.dart';
import 'attachments_screen.controller.dart';

class AttachmentsScreen extends StatelessWidget with ConsoleMixin {
  const AttachmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AttachmentsScreenController());

    Widget itemBuilder(context, index) {
      final eTag = controller.data[index];

      final contents = FileService.to.rootInfo.value.data.objects.where(
        (e) => e.etag == eTag,
      );

      // Missing attachment file
      if (contents.isEmpty) {
        return ListTile(
          title: Text('Missing file: ${eTag.replaceAll('"', '')}'),
          subtitle: const Text(
            'The file might have been deleted already',
            style: TextStyle(color: Colors.orange),
          ),
          leading: const Icon(Iconsax.slash_outline, color: Colors.orange),
          trailing: IconButton(
            icon: const Icon(Iconsax.trash_outline, color: Colors.red),
            onPressed: () => controller.data.remove(eTag),
          ),
        );
      }

      return AttachmentTile(
        contents.first,
        onDelete: () => controller.data.remove(eTag),
      );
    }

    final content = Obx(
      () {
        if (controller.data.isEmpty) {
          return CenteredPlaceholder(
            iconData: Iconsax.attach_square_outline,
            message: 'no_attachments'.tr,
            child: TextButton(
              onPressed: controller.pick,
              child: Text('attach_a_file'.tr),
            ),
          );
        } else {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: controller.data.length,
            itemBuilder: itemBuilder,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 15),
          );
        }
      },
    );

    final appBar = AppBar(
      title: Text('attachments'.tr),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
      actions: [
        TextButton(
          onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
          child: Text('help'.tr),
        ),
        IconButton(
          onPressed: () => Get.backLegacy(result: controller.data),
          icon: const Icon(Icons.check),
        ),
        const SizedBox(width: 10),
      ],
    );

    final floatingActionButton = Obx(
      () => FloatingActionButton(
        onPressed: controller.busy() ? null : controller.pick,
        child: const Icon(Iconsax.add_outline),
      ),
    );

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: content,
    );
  }
}
