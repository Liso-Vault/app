import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
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
            height: 100,
            placeholder: Image.asset(Images.logo, height: 100),
          ),
          const SizedBox(height: 20),
          Text(
            ConfigService.to.appName,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            ConfigService.to.general.app.shortDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
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
        ],
      ),
    );

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'By proceeding, you agree to our ',
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: const TextStyle(color: kAppColor),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        console.info('tap');
                        launchUrlString(
                            ConfigService.to.general.app.links.terms);
                      },
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(color: kAppColor),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launchUrlString(
                          ConfigService.to.general.app.links.privacy),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => Text(
                'v${controller.appVersion}',
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
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
