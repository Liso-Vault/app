import 'package:app_core/config/app.model.dart';
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

import '../../core/utils/globals.dart';
import '../menu/menu.button.dart';
import 'about_screen.controller.dart';

class AboutScreen extends StatelessWidget with ConsoleMixin {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AboutScreenController());
    final links = appConfig.links;

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
                '${appConfig.name} on ${GetPlatform.isIOS || GetPlatform.isMacOS ? 'the App Store' : 'Google Play'}'),
            onTap: () {
              if (GetPlatform.isAndroid) {
                Utils.openUrl(links.store.google);
              } else if (GetPlatform.isIOS || GetPlatform.isMacOS) {
                Utils.openUrl(links.store.apple);
              }
            },
          ),
        ],
        ListTile(
          leading: Icon(Iconsax.chrome, color: themeColor),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: Text('${appConfig.name} Website'),
          subtitle: Text(links.website),
          onTap: () => Utils.openUrl(
            links.website,
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
        // ListTile(
        //   leading: Icon(LineIcons.github, color: themeColor),
        //   title: Text('${appConfig.name} GitHub'),
        //   trailing: const Icon(Iconsax.arrow_right_3),
        //   onTap: () => Utils.openUrl(links.github),
        // ),
        ListTile(
          leading: Icon(Iconsax.security_user, color: themeColor),
          title: Text('${appConfig.name} Privacy'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => Utils.openUrl(links.privacy),
        ),
        ListTile(
          leading: Icon(Iconsax.book_1, color: themeColor),
          title: Text('${appConfig.name} Terms'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => Utils.openUrl(links.terms),
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: Text('faqs'.tr),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => Utils.openUrl(links.faqs),
        ),
        ListTile(
          leading: const Icon(Iconsax.dollar_circle),
          trailing: const Icon(Iconsax.arrow_right_3),
          // TODO: localize
          title: const Text('Earn 30% Commision'),
          subtitle: const Text('Join the Affiliates Program'),
          onTap: () => Utils.openUrl(
            'https://oliverbytes.gumroad.com/affiliates',
          ),
        ),
        if (!GetPlatform.isMobile) ...[
          // ListTile(
          //   leading: Icon(Iconsax.forward_square, color: themeColor),
          //   title: const Text('Invite a friend'),
          //   trailing: const Icon(Iconsax.arrow_right_3),
          //   onTap: () => Share.share(
          //     config.general.app.shareText,
          //     subject: appConfig.name,
          //   ),
          // ),
        ],
        ListTile(
          leading: Icon(Iconsax.code_1, color: themeColor),
          title: Text('licenses'.tr),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => controller.showLicenses(context),
        ),
        // ContextMenuButton(
        //   controller.developerMenuItems,
        //   useMouseRegion: true,
        //   padding: EdgeInsets.zero,
        //   child: ListTile(
        //     leading: Icon(Iconsax.code, color: themeColor),
        //     title: Text('developer'.tr),
        //     trailing: const Icon(Iconsax.arrow_right_3),
        //     onTap: () {},
        //   ),
        // ),
        const Divider(),
        ListTile(
          leading: RemoteImage(
            url: 'https://i.imgur.com/0H0sWlN.png',
            width: 20,
            placeholder: Image.asset(Images.placeholder, height: 20),
          ),
          trailing: const Icon(Iconsax.arrow_right_3),
          title: const Text('NexBot AI Writing Assistant'),
          subtitle: const Text('Create amazing content 10X faster with AI'),
          onTap: () => Utils.openUrl('https://nexbot.ai'),
        ),
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
          title: const Text('NexSnap Screenshot Editor'),
          subtitle: const Text('Make beautiful screenshots in seconds'),
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
