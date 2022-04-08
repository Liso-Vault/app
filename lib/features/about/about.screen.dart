import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/main/main_screen.controller.dart';
import 'package:liso/resources/resources.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'about_screen.controller.dart';

class AboutScreen extends GetWidget<AboutScreenController> with ConsoleMixin {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _content = ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        const SizedBox(height: 20),
        Image.asset(Images.logo, height: 50),
        const SizedBox(height: 15),
        const Text(
          kAppName,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25),
        ),
        const SizedBox(height: 10),
        Text(
          controller.appVersion,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            kAppDescription,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),

        const SizedBox(height: 30),
        const Divider(),
        ListTile(
          leading: Image.asset(
            Images.logo,
            height: 25,
            color: Colors.grey,
          ),
          trailing: const Icon(LineIcons.alternateExternalLink),
          title: const Text('Liso Website'),
          subtitle: const Text(kAppWebsiteUrl),
          onTap: () => launch(kAppWebsiteUrl),
        ),
        // ListTile(
        //   leading: const Icon(LineIcons.github),
        //   trailing: const Icon(LineIcons.alternateExternalLink),
        //   title: const Text('Liso GitHub'),
        //   subtitle: const Text(kAppGithubUrl),
        //   onTap: () => launch(kAppGithubUrl),
        // ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.twitter),
          trailing: const Icon(LineIcons.alternateExternalLink),
          title: const Text('Liso Twitter'),
          subtitle: const Text('@liso_vault'),
          onTap: () => launch(kAppTwitterUrl),
        ),
        // ListTile(
        //   leading: const Icon(LineIcons.instagram),
        //   trailing: const Icon(LineIcons.alternateExternalLink),
        //   title: const Text('Liso Instagram'),
        //   subtitle: const Text('@liso_vault'),
        //   onTap: () => launch(kAppInstagramUrl),
        // ),
        // ListTile(
        //   leading: const Icon(LineIcons.facebook),
        //   trailing: const Icon(LineIcons.alternateExternalLink),
        //   title: const Text('Liso Facebook'),
        //   subtitle: const Text('@liso_vault'),
        //   onTap: () => launch(kAppFacebookUrl),
        // ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.envelope),
          trailing: const Icon(LineIcons.alternateExternalLink),
          title: const Text('Liso Email'),
          subtitle: const Text(kAppEmail),
          onTap: () =>
              launch('mailto:liso.vault@gmail.com?subject=Liso%20Support'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.gift),
          title: const Text('Invite a friend'),
          onTap: () => Share.share(
            kAppShareText,
            subject: kAppName,
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.list),
          title: const Text('Roadmap'),
          onTap: () => launch(kAppRoadmapUrl),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.laptopCode),
          title: const Text('Licenses'),
          onTap: () => controller.showLicenses(context),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(LineIcons.users),
          title: const Text('Community & Help'),
          onTap: () => launch(kAppSupportUrl),
        ),
        // ListTile(
        //   leading: const Icon(LineIcons.download),
        //   trailing: const Icon(LineIcons.alternateExternalLink),
        //   title: const Text('Check for updates'),
        //   subtitle: Obx(() => Text(controller.appVersion)),
        //   onTap: () => launch(kAppGithubReleasesUrl),
        // ),
        // if (kDebugMode) ...[
        //   ListTile(
        //     leading: const Icon(LineIcons.bug),
        //     title: const Text('Window Size'),
        //     onTap: () async {
        //       final size = await DesktopWindow.getWindowSize();
        //       console.info('size: $size');
        //     },
        //   ),
        // ],
        const Divider(),
        const SizedBox(height: 20),
        TextButton.icon(
          icon: const Icon(LineIcons.link),
          label: const Text(kDeveloperWebsite),
          onPressed: () => launch(kDeveloperWebsite),
        ),
        const SizedBox(height: 20),
        TextButton.icon(
          icon: const Icon(LineIcons.twitter),
          label: const Text(kDeveloperTwitterHandle),
          onPressed: () => launch(kDeveloperTwitterUrl),
        ),
        const SizedBox(height: 50),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        // X icon for desktop instead of back for mobile
        leading: MainScreenController.to.expandableDrawer
            ? null
            : IconButton(
                onPressed: Get.back,
                icon: const Icon(LineIcons.times),
              ),
      ),
      body: _content,
    );
  }
}
