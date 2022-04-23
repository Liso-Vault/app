import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/resources/resources.dart';

import '../../core/utils/biometric.util.dart';
import 'welcome_screen.controller.dart';

class WelcomeScreen extends GetView<WelcomeScreenController> with ConsoleMixin {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Container(
      constraints: Styles.containerConstraints,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(Images.logo, width: 100),
          const SizedBox(height: 20),
          const Text(
            kAppName,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            kAppDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const Divider(),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              label: Text('create_vault'.tr),
              icon: const Icon(LineIcons.plus),
              onPressed: () => Get.toNamed(Routes.mnemonic),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            label: Text('import_vault'.tr),
            icon: const Icon(LineIcons.download),
            onPressed: () => Get.toNamed(Routes.import),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            label: const Text('test'),
            icon: const Icon(LineIcons.download),
            onPressed: () async {
              // if (!await BiometricUtils.canAuthenticate()) return;

              // final storage = await BiometricUtils.getStorage(
              //   'test_storage',
              //   title: "Test $kAppName",
              // );

              // try {
              //   await storage.write('test');
              // } catch (e) {
              //   return console.error('biometric error: $e');
              // }

              // console.info('success');

              console.info(
                  'ConfigService.to.s3.endpoint: #${ConfigService.to.s3.endpoint}#');
            },
          ),
        ],
      ),
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomRight,
              child: Obx(
                () => Text(
                  'v${controller.appVersion}',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),
            ),
            Center(child: content)
          ],
        ),
      ),
    );
  }
}
