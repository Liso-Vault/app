import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/utils/globals.dart';
import '../../resources/resources.dart';

class AboutScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AboutScreenController());
  }
}

class AboutScreenController extends GetxController {
  // VARIABLES

  // PROPERTIES
  final packageInfo = Rxn<PackageInfo>();

  // GETTERS
  String get appVersion =>
      '${packageInfo()?.version}+${packageInfo()?.buildNumber}';

  // INIT
  @override
  void onInit() async {
    packageInfo.value = await PackageInfo.fromPlatform();
    super.onInit();
  }

  // FUNCTIONS

  void showLicenses(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();

    final icon = Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Image.asset(Images.logo, height: 50),
    );

    showLicensePage(
      context: context,
      applicationIcon: icon,
      applicationName: packageInfo.appName,
      applicationVersion: appVersion,
      applicationLegalese:
          'Copyright © ${DateTime.now().year} $kDeveloperName\nAll rights reserved.',
    );
  }
}
