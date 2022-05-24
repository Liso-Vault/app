import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/general/remote_image.widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/firebase/config/config.service.dart';
import '../../resources/resources.dart';
import '../menu/menu.item.dart';

class AboutScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AboutScreenController(), fenix: true);
  }
}

class AboutScreenController extends GetxController with ConsoleMixin {
  // VARIABLES

  // PROPERTIES
  final packageInfo = Rxn<PackageInfo>();

  // GETTERS
  String get appVersion =>
      '${packageInfo.value?.version}+${packageInfo.value?.buildNumber}';

  List<ContextMenuItem> get communityMenuItems {
    final links = ConfigService.to.general.app.links;

    return [
      ContextMenuItem(
        title: 'Discord',
        leading: const Icon(LineIcons.discord),
        onSelected: () => launchUrlString(links.discord),
      ),
      ContextMenuItem(
        title: 'Telegram',
        leading: const Icon(LineIcons.telegram),
        onSelected: () => launchUrlString(links.telegram),
      ),
      ContextMenuItem(
        title: 'Twitter',
        leading: const Icon(LineIcons.twitter),
        onSelected: () => launchUrlString(links.twitter),
      ),
      ContextMenuItem(
        title: 'Facebook',
        leading: const Icon(LineIcons.facebook),
        onSelected: () => launchUrlString(links.facebook),
      ),
      ContextMenuItem(
        title: 'Instagram',
        leading: const Icon(LineIcons.instagram),
        onSelected: () => launchUrlString(links.instagram),
      ),
      ContextMenuItem(
        title: 'Email',
        leading: const Icon(LineIcons.envelope),
        onSelected: () => launchUrlString(
          'mailto:${ConfigService.to.general.app.emails.support}?subject=${ConfigService.to.appName}%20Support',
        ),
      ),
    ];
  }

  List<ContextMenuItem> get developerMenuItems {
    final links = ConfigService.to.general.developer.links;

    return [
      ContextMenuItem(
        title: 'Website',
        leading: const Icon(LineIcons.link),
        onSelected: () => launchUrlString(links.website),
      ),
      ContextMenuItem(
        title: 'Twitter',
        leading: const Icon(LineIcons.twitter),
        onSelected: () => launchUrlString(links.twitter),
      ),
      ContextMenuItem(
        title: 'LinkedIn',
        leading: const Icon(LineIcons.linkedin),
        onSelected: () => launchUrlString(links.linkedin),
      ),
      ContextMenuItem(
        title: 'Facebook',
        leading: const Icon(LineIcons.facebook),
        onSelected: () => launchUrlString(links.facebook),
      ),
      ContextMenuItem(
        title: 'Instagram',
        leading: const Icon(LineIcons.instagram),
        onSelected: () => launchUrlString(links.instagram),
      ),
      ContextMenuItem(
        title: 'GitHub',
        leading: const Icon(LineIcons.github),
        onSelected: () => launchUrlString(links.github),
      ),
      ContextMenuItem(
        title: 'Privacy',
        leading: const Icon(LineIcons.userShield),
        onSelected: () => launchUrlString(links.privacy),
      ),
      ContextMenuItem(
        title: 'App Store Page',
        leading: const Icon(LineIcons.appStore),
        onSelected: () => launchUrlString(links.store.apple),
      ),
      ContextMenuItem(
        title: 'Google Play Page',
        leading: const Icon(LineIcons.googlePlay),
        onSelected: () => launchUrlString(links.store.google),
      ),
      ContextMenuItem(
        title: 'Email',
        leading: const Icon(LineIcons.envelope),
        onSelected: () => launchUrlString(
          'mailto:${ConfigService.to.general.developer.emails.support}?subject=${ConfigService.to.devName}%20Support',
        ),
      ),
    ];
  }

  // INIT
  @override
  void onInit() async {
    packageInfo.value = await PackageInfo.fromPlatform();
    console.info('onInit');
    super.onInit();
  }

  // FUNCTIONS

  void showLicenses(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();

    final icon = Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: RemoteImage(
        url: ConfigService.to.general.app.image,
        height: 50,
        placeholder: Image.asset(Images.logo, height: 50),
      ),
    );

    showLicensePage(
      context: context,
      applicationIcon: icon,
      applicationName: packageInfo.appName,
      applicationVersion: appVersion,
      applicationLegalese:
          'Copyright © ${DateTime.now().year} ${ConfigService.to.general.developer.name}\nAll rights reserved.',
    );
  }
}
