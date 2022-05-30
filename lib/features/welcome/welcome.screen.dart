import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/resources/resources.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/firebase/config/config.service.dart';
import '../general/remote_image.widget.dart';
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
          RemoteImage(
            url: ConfigService.to.general.app.image,
            height: 150,
            placeholder: Image.asset(Images.logo, height: 150),
          ),
          const SizedBox(height: 20),
          Text(
            ConfigService.to.appName,
            style: const TextStyle(fontSize: 25),
          ),
          const SizedBox(height: 10),
          Text(
            ConfigService.to.general.app.shortDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          Obx(
            () => Text(
              'v${controller.appVersion}',
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ),
          const Divider(),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              label: Text('create_vault'.tr),
              icon: const Icon(Iconsax.box_add),
              onPressed: () => Get.toNamed(Routes.mnemonic),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            label: Text('import_vault'.tr),
            icon: const Icon(Iconsax.import_1),
            onPressed: () => Get.toNamed(Routes.import),
          ),
        ],
      ),
    );

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('By proceeding, you agree to our'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () =>
                      launchUrlString(ConfigService.to.general.app.links.terms),
                  child: const Text('Terms of Service'),
                ),
                const Text('and'),
                TextButton(
                  onPressed: () => launchUrlString(
                    ConfigService.to.general.app.links.privacy,
                  ),
                  onLongPress: AuthService.to.signOut,
                  child: const Text('Privacy Policy'),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(child: content),
      ),
    );
  }
}
