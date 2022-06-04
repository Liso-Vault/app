import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/beta/disabled_beta_screen.controller.dart';
import 'package:liso/resources/resources.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/utils/utils.dart';
import '../general/remote_image.widget.dart';

class DisabledBetaScreen extends GetView<DisabledBetaScreenController> {
  const DisabledBetaScreen({Key? key}) : super(key: key);

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
            '${ConfigService.to.appName} Beta is done! It is time to switch to the production version!\nWe thank you and appreciate for everything you did to make us production-ready!',
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
              label: const Text('Download'),
              icon: const Icon(Iconsax.document_download),
              onPressed: () => Utils.openUrl(
                ConfigService.to.general.app.links.website,
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(child: content),
      ),
    );
  }
}
