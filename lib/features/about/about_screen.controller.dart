import 'package:app_core/config/app.model.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/remote_image.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../resources/resources.dart';
import '../menu/menu.item.dart';

class AboutScreenController extends GetxController with ConsoleMixin {
  // VARIABLES

  // PROPERTIES

  // GETTERS

  List<ContextMenuItem> get communityMenuItems {
    final links = appConfig.links;

    return [
      ContextMenuItem(
        title: 'Discord',
        leading: Icon(LineAwesome.discord, size: popupIconSize),
        onSelected: () => Utils.openUrl(links.discord),
      ),
      // ContextMenuItem(
      //   title: 'Telegram',
      //   leading: const Icon(LineAwesome.telegram, size: popupIconSize),
      //   onSelected: () => Utils.openUrl(links.telegram),
      // ),
      ContextMenuItem(
        title: 'Twitter',
        leading: Icon(LineAwesome.twitter, size: popupIconSize),
        onSelected: () => Utils.openUrl(links.twitter),
      ),
      // ContextMenuItem(
      //   title: 'Facebook',
      //   leading: const Icon(LineAwesome.facebook, size: popupIconSize),
      //   onSelected: () => Utils.openUrl(links.facebook),
      // ),
      // ContextMenuItem(
      //   title: 'Instagram',
      //   leading: const Icon(LineAwesome.instagram, size: popupIconSize),
      //   onSelected: () => Utils.openUrl(links.instagram),
      // ),
      ContextMenuItem(
        title: 'Email',
        leading: Icon(LineAwesome.envelope, size: popupIconSize),
        onSelected: Utils.contactEmail,
      ),
    ];
  }

//   List<ContextMenuItem> get developerMenuItems {
//     final links = ConfigService.to.general.developer.links;

//     return [
//       ContextMenuItem(
//         title: 'Website',
//         leading: Icon(LineAwesome.link, size: popupIconSize),
//         onSelected: () => Utils.openUrl(links.website),
//       ),
//       ContextMenuItem(
//         title: 'Twitter',
//         leading: Icon(LineAwesome.twitter, size: popupIconSize),
//         onSelected: () => Utils.openUrl(links.twitter),
//       ),
//       // ContextMenuItem(
//       //   title: 'LinkedIn',
//       //   leading: const Icon(LineAwesome.linkedin, size: popupIconSize),
//       //   onSelected: () => Utils.openUrl(links.linkedin),
//       // ),
//       // ContextMenuItem(
//       //   title: 'Facebook',
//       //   leading: const Icon(LineAwesome.facebook, size: popupIconSize),
//       //   onSelected: () => Utils.openUrl(links.facebook),
//       // ),
//       // ContextMenuItem(
//       //   title: 'Instagram',
//       //   leading: const Icon(LineAwesome.instagram, size: popupIconSize),
//       //   onSelected: () => Utils.openUrl(links.instagram),
//       // ),
//       ContextMenuItem(
//         title: 'GitHub',
//         leading: Icon(LineAwesome.github, size: popupIconSize),
//         onSelected: () => Utils.openUrl(links.github),
//       ),
//       ContextMenuItem(
//         title: 'Privacy',
//         leading: Icon(LineAwesome.userShield, size: popupIconSize),
//         onSelected: () => Utils.openUrl(links.privacy),
//       ),
//       ContextMenuItem(
//         title: 'App Store Page',
//         leading: Icon(LineAwesome.appStore, size: popupIconSize),
//         onSelected: () => Utils.openUrl(links.store.apple),
//       ),
//       if (!GetPlatform.isIOS && !GetPlatform.isMacOS) ...[
//         ContextMenuItem(
//           title: 'Google Play Page',
//           leading: Icon(LineAwesome.googlePlay, size: popupIconSize),
//           onSelected: () => Utils.openUrl(links.store.google),
//         ),
//       ],
//     ];
// }

// INIT

// FUNCTIONS

  void showLicenses(BuildContext context) async {
    final icon = Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: RemoteImage(
        url: 'https://i.imgur.com/GW4HQ1r.png',
        height: 50,
        failWidget: Image.asset(Images.logo, height: 50),
      ),
    );

    showLicensePage(
      context: context,
      applicationIcon: icon,
      applicationName: metadataApp.appName,
      applicationVersion: metadataApp.formattedVersion,
      applicationLegalese:
          'Copyright © 2022 ${appConfig.dev}\nAll rights reserved.',
    );
  }
}
