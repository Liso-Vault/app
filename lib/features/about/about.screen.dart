import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/resources/resources.dart';
import 'package:url_launcher/url_launcher.dart';

import 'about_screen.controller.dart';

class AboutScreen extends GetView<AboutScreenController> {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _content = ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        Image.asset(Images.logo, height: 50),
        const SizedBox(height: 15),
        const Text(
          kAppName,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17),
        ),
        const SizedBox(height: 10),
        const Text(
          kAppDescription,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 30),
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
        ListTile(
          leading: const Icon(LineIcons.github),
          trailing: const Icon(LineIcons.alternateExternalLink),
          title: const Text('Liso GitHub'),
          subtitle: const Text(kAppGithubUrl),
          onTap: () => launch(kAppGithubUrl),
        ),
        ListTile(
          leading: const Icon(LineIcons.twitter),
          trailing: const Icon(LineIcons.alternateExternalLink),
          title: const Text('Liso Twitter'),
          subtitle: const Text('@liso_vault'),
          onTap: () => launch(kAppTwitterUrl),
        ),
        ListTile(
          leading: const Icon(LineIcons.instagram),
          trailing: const Icon(LineIcons.alternateExternalLink),
          title: const Text('Liso Instagram'),
          subtitle: const Text('@liso_vault'),
          onTap: () => launch(kAppInstagramUrl),
        ),
        ListTile(
          leading: const Icon(LineIcons.facebook),
          trailing: const Icon(LineIcons.alternateExternalLink),
          title: const Text('Liso Facebook'),
          subtitle: const Text('@liso_vault'),
          onTap: () => launch(kAppFacebookUrl),
        ),
        const SizedBox(height: 20),
        TextButton.icon(
          icon: const Icon(LineIcons.twitter),
          label: const Text(kDeveloperTwitterHandle),
          onPressed: () => launch(kDeveloperTwitterUrl),
        ),
        const Text(
          'Developer',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 50),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Container(
        constraints: Styles.containerConstraints,
        child: _content,
      ),
    );
  }
}
