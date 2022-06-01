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

class DevicesScreen extends GetView<DevicesScreenController> with ConsoleMixin {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget itemBuilder(context, index) {
      final device = controller.data[index];

      final menuItems = [
        if (device.id != Globals.metadata.device.id) ...[
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

      final isThisDevice = device.id == Globals.metadata.device.id;

      return ListTile(
        title: Text(device.model),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(device.id),
            if (isThisDevice) ...[
              Row(
                children: [
                  Icon(LineIcons.check, color: themeColor, size: 15),
                  const SizedBox(width: 5),
                  Text(
                    'This device',
                    style: TextStyle(color: themeColor),
                  ),
                ],
              )
            ]
          ],
        ),
        leading: Icon(isThisDevice ? Iconsax.cpu : LineIcons.syncIcon),
        trailing: ContextMenuButton(
          menuItems,
          child: const Icon(LineIcons.verticalEllipsis),
        ),
        onTap: () {
          //
        },
      );
    }

    final listView = Obx(
      () => ListView.separated(
        shrinkWrap: true,
        itemCount: controller.data.length,
        itemBuilder: itemBuilder,
        physics: const AlwaysScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const Divider(height: 0),
      ),
    );

    final content = controller.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onError: (message) => CenteredPlaceholder(
        iconData: Iconsax.warning_2,
        message: message!,
        child: TextButton(
          onPressed: controller.load,
          child: Text('try_again'.tr),
        ),
      ),
    );

    final appBar = AppBar(
      title: Text('devices'.tr),
      centerTitle: controller.enforce,
      leading: controller.enforce
          ? const SizedBox.shrink()
          : const AppBarLeadingButton(),
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
                  onPressed: () =>
                      Utils.adaptiveRouteOpen(name: Routes.upgrade),
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
