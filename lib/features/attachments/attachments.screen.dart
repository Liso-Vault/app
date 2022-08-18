import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/attachments/attachment.tile.dart';

import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../general/appbar_leading.widget.dart';
import '../general/centered_placeholder.widget.dart';
import '../s3/s3.service.dart';
import 'attachments_screen.controller.dart';

class AttachmentsScreen extends StatelessWidget with ConsoleMixin {
  const AttachmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AttachmentsScreenController());

    Widget itemBuilder(context, index) {
      final eTag = controller.data[index];

      final contents = S3Service.to.contentsCache.where(
        (e) => e.object!.eTag == eTag,
      );

      // Missing attachment file
      if (contents.isEmpty) {
        return ListTile(
          title: Text('Missing file: ${eTag.replaceAll('"', '')}'),
          subtitle: const Text(
            'The file might have been deleted already',
            style: TextStyle(color: Colors.orange),
          ),
          leading: const Icon(Iconsax.slash, color: Colors.orange),
          trailing: IconButton(
            icon: const Icon(Iconsax.trash, color: Colors.red),
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
            iconData: Iconsax.attach_square,
            message: 'No Attachments',
            child: TextButton(
              onPressed: controller.pick,
              child: const Text('Attach a File'),
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
      title: const Text('Attachments'),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
      actions: [
        TextButton(
          onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
          child: const Text('Help ?'),
        ),
        IconButton(
          onPressed: () => Get.back(result: controller.data),
          icon: const Icon(LineIcons.check),
        ),
        const SizedBox(width: 10),
      ],
    );

    final floatingActionButton = Obx(
      () => FloatingActionButton(
        onPressed: controller.busy() ? null : controller.pick,
        child: const Icon(Iconsax.add),
      ),
    );

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: content,
    );
  }
}
