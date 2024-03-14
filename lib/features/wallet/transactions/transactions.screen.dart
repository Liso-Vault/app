import 'package:app_core/widgets/busy_indicator.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:liso/features/general/keep_alive.widget.dart';

import '../../general/centered_placeholder.widget.dart';
import 'transactions_screen.controller.dart';

class TransactionsScreen extends StatelessWidget with ConsoleMixin {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransactionsScreenController());

    final listView = Obx(
      () => ListView.builder(
        itemCount: controller.data.length,
        shrinkWrap: true,
        controller: ScrollController(),
        itemBuilder: (context, index) {
          final receipt = controller.data[index];
          return ListTile(
            title: Text(receipt.from),
            subtitle: Text('${receipt.to}'),
          );
        },
      ),
    );

    final content = controller.obx(
      (_) => listView,
      onLoading: const BusyIndicator(),
      onEmpty: CenteredPlaceholder(
        iconData: Iconsax.activity_outline,
        message: 'No Activity',
        child: TextButton.icon(
          icon: const Icon(Iconsax.refresh_outline),
          onPressed: controller.load,
          label: Text(
            'refresh'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );

    return KeepAliveWrapper(child: content);
  }
}
