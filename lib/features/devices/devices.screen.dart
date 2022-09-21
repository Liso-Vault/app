import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/globals.dart';

import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import '../general/centered_placeholder.widget.dart';
import '../json_viewer/json_viewer.screen.dart';
import '../menu/menu.button.dart';
import '../menu/menu.item.dart';
import 'devices_screen.controller.dart';

class DevicesScreen extends StatelessWidget with ConsoleMixin {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DevicesScreenController());

    Widget itemBuilder(context, index) {
      final device = controller.data[index];

      final menuItems = [
        if (device.id != Globals.metadata!.device.id) ...[
          ContextMenuItem(
            title: 'unsync'.tr,
            leading: const Icon(Iconsax.slash),
            onSelected: () => controller.unsync(device),
          ),
        ],
        ContextMenuItem(
          title: 'details'.tr,
          leading: const Icon(Iconsax.code),
          onSelected: () => Get.to(
            () => JSONViewerScreen(data: device.toJson()),
          ),
        ),
      ];

      final isThisDevice = device.id == Globals.metadata?.device.id;

      return ListTile(
        title: Text(device.model, maxLines: 1),
        selected: isThisDevice,
        leading: Icon(isThisDevice ? Icons.check : LineIcons.laptop),
        trailing: ContextMenuButton(
          menuItems,
          child: const Icon(LineIcons.verticalEllipsis),
        ),
        subtitle: Text(
          device.id,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
        onTap: () {
          //
        },
      );
    }

    final listView = Obx(
      () => ListView.builder(
        shrinkWrap: true,
        itemCount: controller.data.length,
        itemBuilder: itemBuilder,
        physics: const AlwaysScrollableScrollPhysics(),
      ),
    );

    final content = controller.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onError: (message) => CenteredPlaceholder(
        iconData: Iconsax.warning_2,
        message: message!,
        child: TextButton(
          onPressed: controller.restart,
          child: Text('try_again'.tr),
        ),
      ),
    );

    final appBar = AppBar(
      title: Obx(
        () => Text('${controller.data.length} ${'devices'.tr}'),
      ),
      centerTitle: controller.enforce,
      leading: controller.enforce
          ? const SizedBox.shrink()
          : const AppBarLeadingButton(),
      actions: [
        TextButton(
          onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
          child: const Text('Need Help ?'),
        ),
      ],
    );

    final bottomBar = controller.enforce
        ? Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Unsync a previously synced device to allow this new device to sync. Or upgrade to Pro for more device sync limits.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => Utils.adaptiveRouteOpen(
                    name: Routes.upgrade,
                  ),
                  label: const Text('Upgrade to Pro'),
                  icon: const Icon(LineIcons.rocket),
                ),
                const Divider(),
                const Text(
                  'Upgrade for a better overall experience and more security',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
          )
        : null;

    return WillPopScope(
      onWillPop: () => Future.value(!controller.enforce),
      child: Scaffold(
        appBar: appBar,
        bottomNavigationBar: bottomBar,
        body: content,
      ),
    );
  }
}
