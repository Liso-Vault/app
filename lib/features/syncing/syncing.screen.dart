import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:liso/features/syncing/syncing_screen.controller.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../general/centered_placeholder.widget.dart';

class SyncingScreen extends GetView<SyncingScreenController> {
  const SyncingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loading = Material(
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
            Text('${'syncing'.tr}...'),
          ],
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: controller.obx(
        (state) => loading,
        onLoading: loading,
        onError: (message) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: controller.cancel,
              icon: const Icon(LineIcons.times),
            ),
          ),
          body: CenteredPlaceholder(
            iconData: Iconsax.warning_2,
            message: message!,
            child: TextButton.icon(
              label: Text('try_again'.tr),
              icon: const Icon(Iconsax.refresh),
              onPressed: controller.sync,
            ),
          ),
        ),
      ),
    );
  }
}
