import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/resources/resources.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/utils/utils.dart';
import '../general/remote_image.widget.dart';
import '../general/version.widget.dart';
import 'welcome_screen.controller.dart';

class WelcomeScreen extends StatelessWidget with ConsoleMixin {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WelcomeScreenController());

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
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              label: Text('create_vault'.tr),
              icon: const Icon(Iconsax.box_add),
              onPressed: controller.create,
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            label: Text('restore_vault'.tr),
            icon: const Icon(Iconsax.import_1),
            onPressed: controller.import,
          ),
        ],
      ),
    );

    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('By proceeding, you agree to our'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => Utils.openUrl(
                  ConfigService.to.general.app.links.terms,
                ),
                child: const Text('Terms of Use'),
              ),
              const Text('and'),
              TextButton(
                onPressed: () => Utils.openUrl(
                  ConfigService.to.general.app.links.privacy,
                ),
                child: const Text('Privacy Policy'),
              ),
            ],
          ),
          const VersionText()
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(child: content),
      ),
    );
  }
}
