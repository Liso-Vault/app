import 'package:app_core/firebase/config/config.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:app_core/widgets/remote_image.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/resources/resources.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/globals.dart';
import '../menu/menu.button.dart';
import 'about_screen.controller.dart';

class AboutScreen extends StatelessWidget with ConsoleMixin {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AboutScreenController());

    final config = Get.find<ConfigService>();

    final content = ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        if (isRateReviewSupported) ...[
          ListTile(
            leading: Icon(
              GetPlatform.isAndroid ? LineIcons.googlePlay : LineIcons.appStore,
              color: themeColor,
            ),
            trailing: const Icon(Iconsax.arrow_right_3),
            title: Text(
                '${ConfigService.to.appName} on ${GetPlatform.isIOS || GetPlatform.isMacOS ? 'the App Store' : 'Google Play'}'),
            onTap: () {
              final store = ConfigService.to.general.app.links.store;

              if (GetPlatform.isAndroid) {
                Utils.openUrl(store.google);
              } else if (GetPlatform.isIOS || GetPlatform.isMacOS) {
                Utils.openUrl(store.apple);
              }
            },
          ),
        ],
        ListTile(
          leading: Icon(Iconsax.chrome, color: themeColor),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: Text('${config.appName} Website'),
          subtitle: Text(config.general.app.links.website),
          onTap: () => Utils.openUrl(
            config.general.app.links.website,
          ),
        ),
        ListTile(
          leading: Icon(LineIcons.rocket, color: themeColor),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: Text('${config.appName} Roadmap'),
          onTap: () => Utils.openUrl(
            config.general.app.links.roadmap,
          ),
        ),
        ContextMenuButton(
          controller.communityMenuItems,
          useMouseRegion: true,
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(Iconsax.profile_2user, color: themeColor),
            title: Text('community_help'.tr),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () {},
          ),
        ),
        ListTile(
          leading: Icon(LineIcons.productHunt, color: themeColor),
          title: Text('${config.appName} Product Hunt'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => Utils.openUrl(config.general.app.links.productHunt),
        ),
        ListTile(
          leading: Icon(LineIcons.git, color: themeColor),
          title: Text('${config.appName} GitCoin Grants'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => Utils.openUrl(
              'https://gitcoin.co/grants/5819/liso-decentralized-password-manager'),
        ),
        ListTile(
          leading: Icon(LineIcons.github, color: themeColor),
          title: Text('${config.appName} GitHub'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => Utils.openUrl(config.general.app.links.github),
        ),
        ListTile(
          leading: Icon(Iconsax.security_user, color: themeColor),
          title: Text('${config.appName} Privacy'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => Utils.openUrl(config.general.app.links.privacy),
        ),
        ListTile(
          leading: Icon(Iconsax.book_1, color: themeColor),
          title: Text('${config.appName} Terms'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => Utils.openUrl(config.general.app.links.terms),
        ),
        if (!GetPlatform.isMobile) ...[
          ListTile(
            leading: Icon(Iconsax.forward_square, color: themeColor),
            title: const Text('Invite a friend'),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () => Share.share(
              config.general.app.shareText,
              subject: config.appName,
            ),
          ),
          // ListTile(
          //   leading: const Icon(LineIcons.download),
          //   trailing: const Icon(Iconsax.arrow_right_3),
          //   title: const Text('Check for updates'),
          //   subtitle: Obx(() => Text(controller.appVersion)),
          //   onTap: () => Utils.openUrl(kAppGithubReleasesUrl),
          // ),
        ],
        ListTile(
          leading: Icon(Iconsax.code_1, color: themeColor),
          title: Text('licenses'.tr),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => controller.showLicenses(context),
        ),
        ContextMenuButton(
          controller.developerMenuItems,
          useMouseRegion: true,
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(Iconsax.code, color: themeColor),
            title: Text('developer'.tr),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () {},
          ),
        ),
        const Divider(),
        ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: RemoteImage(
              url: 'https://i.imgur.com/a25B2yQ.png',
              width: 20,
              placeholder: Image.asset(Images.placeholder, height: 20),
            ),
          ),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: const Text('NexSnap: Make beautiful screenshots'),
          subtitle: const Text('Another app from us you need to try'),
          onTap: () => Utils.openUrl('https://nexsnap.app'),
        ),
        const SizedBox(height: 50),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('about'.tr),
        centerTitle: false,
        leading: const AppBarLeadingButton(),
      ),
      body: content,
    );
  }
}
