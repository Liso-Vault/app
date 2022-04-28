import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/general/appbar_leading.widget.dart';
import 'package:liso/resources/resources.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/firebase/config/config.service.dart';
import '../general/remote_image.widget.dart';
import '../menu/menu.button.dart';
import 'about_screen.controller.dart';

class AboutScreen extends GetWidget<AboutScreenController> with ConsoleMixin {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _content = ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        const SizedBox(height: 30),
        GestureDetector(
          child: RemoteImage(
            url: ConfigService.to.general.app.image,
            height: 50,
            placeholder: Image.asset(Images.logo, height: 50),
          ),
          onLongPress: () {
            PersistenceService.to.proTester.val = true;

            UIUtils.showSnackBar(
              title: 'PRO Tester',
              message: "PRO Tester mode has been enabled",
            );
          },
        ),
        const SizedBox(height: 15),
        Text(
          ConfigService.to.appName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 25),
        ),
        Obx(
          () => Text(
            controller.appVersion,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            ConfigService.to.general.app.shortDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),

        const SizedBox(height: 30),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.link),
          trailing: const Icon(LineIcons.alternateExternalLink),
          title: Text('${ConfigService.to.appName} Website'),
          subtitle: Text(ConfigService.to.general.app.links.website),
          onTap: () => launchUrlString(
            ConfigService.to.general.app.links.website,
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.rocket),
          title: Text('${ConfigService.to.appName} Roadmap'),
          onTap: () => launchUrlString(
            ConfigService.to.general.app.links.roadmap,
          ),
          trailing: const Icon(LineIcons.alternateExternalLink),
        ),
        const Divider(),
        ContextMenuButton(
          controller.communityMenuItems,
          useMouseRegion: true,
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(LineIcons.users),
            title: Text('community_help'.tr),
            trailing: const Icon(LineIcons.alternateExternalLink),
            onTap: () {},
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.userShield),
          title: Text('${ConfigService.to.appName} Privacy'),
          trailing: const Icon(LineIcons.alternateExternalLink),
          onTap: () =>
              launchUrlString(ConfigService.to.general.app.links.privacy),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.bookOpen),
          title: Text('${ConfigService.to.appName} Terms'),
          trailing: const Icon(LineIcons.alternateExternalLink),
          onTap: () =>
              launchUrlString(ConfigService.to.general.app.links.terms),
        ),

        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.gift),
          title: const Text('Invite a friend'),
          trailing: const Icon(LineIcons.share),
          onTap: () => Share.share(
            ConfigService.to.general.app.shareText,
            subject: ConfigService.to.appName,
          ),
        ),
        // ListTile(
        //   leading: const Icon(LineIcons.download),
        //   trailing: const Icon(LineIcons.alternateExternalLink),
        //   title: const Text('Check for updates'),
        //   subtitle: Obx(() => Text(controller.appVersion)),
        //   onTap: () => launchUrlString(kAppGithubReleasesUrl),
        // ),
        const Divider(),
        ContextMenuButton(
          controller.developerMenuItems,
          useMouseRegion: true,
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: RemoteImage(
              url: ConfigService.to.general.developer.image,
              height: 23,
              width: 23,
              placeholder: Image.asset(Images.stackwares, height: 23),
            ),
            title: Text('developer'.tr),
            subtitle: Text(ConfigService.to.devName),
            trailing: const Icon(LineIcons.alternateExternalLink),
            onTap: () {},
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.laptopCode),
          title: Text('licenses'.tr),
          onTap: () => controller.showLicenses(context),
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
      body: _content,
    );
  }
}
