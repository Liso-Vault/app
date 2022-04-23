import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:liso/features/sync/syncing/syncing_screen.controller.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../general/centered_placeholder.widget.dart';

class SyncingScreen extends GetView<SyncingScreenController> {
  const SyncingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = controller.obx(
      (_) => const Material(child: SizedBox.shrink()),
      onLoading: Material(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(
                () => CircularPercentIndicator(
                  radius: 25,
                  lineWidth: 6.0,
                  percent: S3Service.to.progressValue.value,
                  progressColor: Get.theme.primaryColor,
                  backgroundColor:
                      Get.isDarkMode ? Colors.grey.shade600 : Colors.grey,
                ),
              ),
              const SizedBox(height: 15),
              const Text('Syncing...'),
            ],
          ),
        ),
      ),
      onError: (message) => Material(
        child: CenteredPlaceholder(
          iconData: LineIcons.exclamationTriangle,
          message: message!,
          child: TextButton.icon(
            label: const Text('Try again'),
            icon: const Icon(LineIcons.syncIcon),
            onPressed: controller.sync,
          ),
        ),
      ),
    );

    final appBar = AppBar(
      leading: controller.obx(
        (state) => const SizedBox.shrink(),
        onLoading: const SizedBox.shrink(),
        onError: (message) => IconButton(
          onPressed: controller.cancel,
          icon: const Icon(LineIcons.times),
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: appBar,
        body: content,
      ),
    );
  }
}
