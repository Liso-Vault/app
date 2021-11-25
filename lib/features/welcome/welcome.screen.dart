import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/resources/resources.dart';

import 'welcome_screen.controller.dart';

class WelcomeScreen extends GetView<WelcomeScreenController> with ConsoleMixin {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            Center(
              child: Container(
                constraints: Styles.containerConstraints,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(Images.logo, width: 100),
                    const SizedBox(height: 20),
                    const Text(
                      kName,
                      style: TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      kDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 50),
                    TextButton.icon(
                      label: const Text('Create'),
                      icon: const Icon(LineIcons.plus),
                      onPressed: () => Get.toNamed(Routes.createPassword),
                    ),
                    const SizedBox(height: 15),
                    TextButton.icon(
                      label: const Text('Import'),
                      icon: const Icon(LineIcons.download),
                      onPressed: () => Get.toNamed(Routes.import),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
