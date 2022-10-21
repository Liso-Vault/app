import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/features/general/remote_image.widget.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../../resources/resources.dart';
import '../menu/menu.item.dart';

class AboutScreenController extends GetxController with ConsoleMixin {
  // VARIABLES

  // PROPERTIES

  // GETTERS

  List<ContextMenuItem> get communityMenuItems {
    final links = ConfigService.to.general.app.links;

    return [
      ContextMenuItem(
        title: 'Discord',
        leading: Icon(LineIcons.discord, size: popupIconSize),
        onSelected: () => Utils.openUrl(links.discord),
      ),
      // ContextMenuItem(
      //   title: 'Telegram',
      //   leading: const Icon(LineIcons.telegram, size: popupIconSize),
      //   onSelected: () => Utils.openUrl(links.telegram),
      // ),
      ContextMenuItem(
        title: 'Twitter',
        leading: Icon(LineIcons.twitter, size: popupIconSize),
        onSelected: () => Utils.openUrl(links.twitter),
      ),
      // ContextMenuItem(
      //   title: 'Facebook',
      //   leading: const Icon(LineIcons.facebook, size: popupIconSize),
      //   onSelected: () => Utils.openUrl(links.facebook),
      // ),
      // ContextMenuItem(
      //   title: 'Instagram',
      //   leading: const Icon(LineIcons.instagram, size: popupIconSize),
      //   onSelected: () => Utils.openUrl(links.instagram),
      // ),
      ContextMenuItem(
        title: 'Email',
        leading: Icon(LineIcons.envelope, size: popupIconSize),
        onSelected: Utils.contactEmail,
      ),
    ];
  }

  List<ContextMenuItem> get developerMenuItems {
    final links = ConfigService.to.general.developer.links;

    return [
      ContextMenuItem(
        title: 'Website',
        leading: Icon(LineIcons.link, size: popupIconSize),
        onSelected: () => Utils.openUrl(links.website),
      ),
      ContextMenuItem(
        title: 'Twitter',
        leading: Icon(LineIcons.twitter, size: popupIconSize),
        onSelected: () => Utils.openUrl(links.twitter),
      ),
      // ContextMenuItem(
      //   title: 'LinkedIn',
      //   leading: const Icon(LineIcons.linkedin, size: popupIconSize),
      //   onSelected: () => Utils.openUrl(links.linkedin),
      // ),
      // ContextMenuItem(
      //   title: 'Facebook',
      //   leading: const Icon(LineIcons.facebook, size: popupIconSize),
      //   onSelected: () => Utils.openUrl(links.facebook),
      // ),
      // ContextMenuItem(
      //   title: 'Instagram',
      //   leading: const Icon(LineIcons.instagram, size: popupIconSize),
      //   onSelected: () => Utils.openUrl(links.instagram),
      // ),
      ContextMenuItem(
        title: 'GitHub',
        leading: Icon(LineIcons.github, size: popupIconSize),
        onSelected: () => Utils.openUrl(links.github),
      ),
      ContextMenuItem(
        title: 'Privacy',
        leading: Icon(LineIcons.userShield, size: popupIconSize),
        onSelected: () => Utils.openUrl(links.privacy),
      ),
      ContextMenuItem(
        title: 'App Store Page',
        leading: Icon(LineIcons.appStore, size: popupIconSize),
        onSelected: () => Utils.openUrl(links.store.apple),
      ),
      if (!GetPlatform.isIOS && !GetPlatform.isMacOS) ...[
        ContextMenuItem(
          title: 'Google Play Page',
          leading: Icon(LineIcons.googlePlay, size: popupIconSize),
          onSelected: () => Utils.openUrl(links.store.google),
        ),
      ],
    ];
  }

  // INIT

  // FUNCTIONS

  void showLicenses(BuildContext context) async {
    final app = Globals.metadata!.app;

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
      applicationName: app.appName,
      applicationVersion: app.formattedVersion,
      applicationLegalese:
          'Copyright © ${DateTime.now().year} ${ConfigService.to.general.developer.name}\nAll rights reserved.',
    );
  }
}
