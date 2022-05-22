import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/general/appbar_leading.widget.dart';
import 'package:liso/resources/resources.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/utils/globals.dart';
import '../general/remote_image.widget.dart';
import '../menu/menu.button.dart';
import 'about_screen.controller.dart';

class AboutScreen extends GetView<AboutScreenController> with ConsoleMixin {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = Get.find<ConfigService>();
    final persistence = Get.find<Persistence>();

    final content = ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        const Divider(),
        ListTile(
          leading: RemoteImage(
            url: config.general.app.image,
            height: 20,
            placeholder: Image.asset(Images.logo, height: 20),
          ),
          title: Obx(() => Text('${config.appName} v${controller.appVersion}')),
          onLongPress: () {
            persistence.proTester.val = !persistence.proTester.val;

            UIUtils.showSnackBar(
              title: 'PRO Tester',
              message: "PRO Tester mode has been enabled",
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: Icon(Iconsax.chrome, color: themeColor),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: Text('${config.appName} Website'),
          subtitle: Text(config.general.app.links.website),
          onTap: () => launchUrlString(
            config.general.app.links.website,
          ),
        ),
        const Divider(),
        ListTile(
          leading: Icon(LineIcons.rocket, color: themeColor),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: Text('${config.appName} Roadmap'),
          onTap: () => launchUrlString(
            config.general.app.links.roadmap,
          ),
        ),
        const Divider(),
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
        const Divider(),
        ListTile(
          leading: Icon(LineIcons.productHunt, color: themeColor),
          title: Text('${config.appName} Product Hunt'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => launchUrlString(config.general.app.links.productHunt),
        ),
        const Divider(),
        // TODO: Add GitCoin link
        // ListTile(
        //   leading: Icon(LineIcons.git, color: themeColor),
        //   title: Text('${config.appName} GitCoin'),
        //   trailing: const Icon(Iconsax.arrow_right_3),
        //   onTap: () => launchUrlString(config.general.app.links.gitcoin),
        // ),
        // const Divider(),
        ListTile(
          leading: Icon(LineIcons.github, color: themeColor),
          title: Text('${config.appName} GitHub'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => launchUrlString(config.general.app.links.github),
        ),
        const Divider(),
        ListTile(
          leading: Icon(Iconsax.security_user, color: themeColor),
          title: Text('${config.appName} Privacy'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => launchUrlString(config.general.app.links.privacy),
        ),
        const Divider(),
        ListTile(
          leading: Icon(Iconsax.book_1, color: themeColor),
          title: Text('${config.appName} Terms'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => launchUrlString(config.general.app.links.terms),
        ),
        if (!GetPlatform.isMobile) ...[
          const Divider(),
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
          //   onTap: () => launchUrlString(kAppGithubReleasesUrl),
          // ),
        ],
        const Divider(),
        ListTile(
          leading: Icon(Iconsax.code_1, color: themeColor),
          title: Text('licenses'.tr),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => controller.showLicenses(context),
        ),
        const Divider(),
        ContextMenuButton(
          controller.developerMenuItems,
          useMouseRegion: true,
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: RemoteImage(
              url: config.general.developer.image,
              height: 23,
              width: 23,
              placeholder: Image.asset(Images.stackwares, height: 23),
            ),
            title: Text('developer'.tr),
            subtitle: Text(config.devName),
            trailing: const Icon(Iconsax.arrow_right_3),
            onTap: () {},
          ),
        ),
        const Divider(),
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
