import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/firebase/analytics.service.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/resources/resources.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../general/remote_image.widget.dart';
import '../general/version.widget.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({Key? key}) : super(key: key);

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
            placeholder: Image.asset(Images.logo, height: 200),
          ),
          const SizedBox(height: 40),
          const Text(
            'Update Required',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Please update to the latest version to enjoy the latest features, bug fixes, and security patches.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              label: const Text('Download'),
              icon: const Icon(Iconsax.arrow_down_2),
              onPressed: () {
                AnalyticsService.to.logEvent('download_required_update');

                Utils.openUrl(
                  ConfigService.to.general.app.links.website,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          Text(
            'Current build # ${Globals.metadata?.app.buildNumber}',
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            'Minimum build # ${ConfigService.to.app.build.min}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        bottomNavigationBar: const VersionText(),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(child: content),
        ),
      ),
    );
  }
}
