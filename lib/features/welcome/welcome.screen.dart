import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/resources/resources.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/utils/utils.dart';
import '../general/busy_indicator.widget.dart';
import '../general/remote_image.widget.dart';
import '../general/version.widget.dart';
import 'welcome_screen.controller.dart';

class WelcomeScreen extends StatelessWidget with ConsoleMixin {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WelcomeScreenController());

    final content = Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: Styles.containerConstraints,
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (Utils.isSmallScreen) ...[
                const SizedBox(height: 100),
              ],
              RemoteImage(
                url: ConfigService.to.general.app.image,
                height: 150,
                placeholder: Image.asset(Images.logo, height: 200),
              ),
              const SizedBox(height: 40),
              const Text(
                'Get Secured Now',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                ConfigService.to.general.app.longDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      label: Text('create_vault'.tr),
                      icon: const Icon(Iconsax.box_add),
                      onPressed: controller.create,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: OutlinedButton.icon(
                      label: Text('restore_vault'.tr),
                      icon: const Icon(Iconsax.import_1),
                      onPressed: controller.restore,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );

    final bottomBar = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'By proceeding, you agree to our',
          style: TextStyle(fontSize: 11),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => Utils.openUrl(
                ConfigService.to.general.app.links.terms,
              ),
              child: const Text(
                'Terms of Use',
                style: TextStyle(fontSize: 11),
              ),
            ),
            const Text(
              'and',
              style: TextStyle(fontSize: 11),
            ),
            TextButton(
              onPressed: () => Utils.openUrl(
                ConfigService.to.general.app.links.privacy,
              ),
              child: const Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
        const VersionText(),
      ],
    );

    const darkDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Colors.black,
          Color(0xFF173030),
        ],
      ),
    );

    return Container(
      decoration: Get.isDarkMode ? darkDecoration : null,
      child: Scaffold(
        backgroundColor: Get.isDarkMode ? Colors.transparent : null,
        bottomNavigationBar: bottomBar,
        body: controller.obx(
          (_) => content,
          onLoading: const BusyIndicator(),
        ),
      ),
    );
  }
}
