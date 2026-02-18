import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/purchases/purchases.services.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:app_core/widgets/busy_indicator.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:icons_plus/icons_plus.dart';

import '../general/centered_placeholder.widget.dart';
import '../json_viewer/json_viewer.screen.dart';
import '../menu/menu.button.dart';
import '../menu/menu.item.dart';
import 'devices_screen.controller.dart';

class DevicesScreen extends StatelessWidget with ConsoleMixin {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DevicesScreenController());

    Widget itemBuilder(context, index) {
      final device = controller.data[index];

      final menuItems = [
        if (device.id != metadataDevice.id) ...[
          ContextMenuItem(
            title: 'unsync'.tr,
            leading: Icon(Iconsax.slash_outline, size: popupIconSize),
            onSelected: () => controller.unsync(device),
          ),
        ],
        ContextMenuItem(
          title: 'details'.tr,
          leading: Icon(Iconsax.code_outline, size: popupIconSize),
          onSelected: () => Get.to(
            () => JSONViewerScreen(data: device.toJson()),
          ),
        ),
      ];

      final isThisDevice = device.id == metadataDevice.id;

      return ListTile(
        title: Text(device.model, maxLines: 1),
        selected: isThisDevice,
        leading: Icon(isThisDevice ? Icons.check : LineAwesome.laptop_solid),
        trailing: ContextMenuButton(
          menuItems,
          child: const Icon(LineAwesome.ellipsis_v_solid),
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
        iconData: Iconsax.warning_2_outline,
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
          child: Text('need_help'.tr),
        ),
      ],
    );

    final bottomBar = controller.enforce
        ? Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'unsync_device_desc'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => PurchasesService.to.show(),
                  label: Text('upgrade_to_pro'.tr),
                  icon: const Icon(LineAwesome.rocket_solid),
                ),
                const Divider(),
                Text(
                  'upgrade_for_better_experience'.tr,
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
