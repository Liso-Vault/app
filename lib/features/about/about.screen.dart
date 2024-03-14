import 'package:app_core/config.dart';
import 'package:app_core/config/app.model.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:app_core/widgets/remote_image.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:icons_plus/icons_plus.dart';
import 'package:liso/resources/resources.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/globals.dart';
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
              GetPlatform.isAndroid
                  ? LineAwesome.google_play
                  : LineAwesome.app_store,
              color: themeColor,
            ),
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
          leading: Icon(Iconsax.chrome_outline, color: themeColor),
          title: Text('${appConfig.name} Website'),
          subtitle: Text(links.website),
          onTap: () => Utils.openUrl(
            links.website,
          ),
        ),
        // ContextMenuButton(
        //   controller.communityMenuItems,
        //   useMouseRegion: true,
        //   padding: EdgeInsets.zero,
        //   child: ListTile(
        //     leading: Icon(Iconsax.profile_2user, color: themeColor),
        //     title: Text('community_help'.tr),
        //     onTap: () {},
        //   ),
        // ),
        ListTile(
          leading: Icon(LineAwesome.github, color: themeColor),
          title: Text('${appConfig.name} GitHub'),
          onTap: () => Utils.openUrl('https://github.com/Liso-Vault/app'),
        ),
        ListTile(
          leading: Icon(Iconsax.security_user_outline, color: themeColor),
          title: Text('${appConfig.name} Privacy'),
          onTap: () => Utils.openUrl(links.privacy),
        ),
        ListTile(
          leading: Icon(Iconsax.book_1_outline, color: themeColor),
          title: Text('${appConfig.name} Terms'),
          onTap: () => Utils.openUrl(links.terms),
        ),
        ListTile(
          leading: Icon(Icons.help_outline, color: themeColor),
          title: Text('faqs'.tr),
          onTap: () => Utils.openUrl(links.faqs),
        ),
        ListTile(
          leading: Icon(Iconsax.dollar_circle_outline, color: themeColor),
          // TODO: localize
          title: const Text('Earn 30% Commision'),
          subtitle: const Text('Join the Affiliates Program'),
          onTap: () => Utils.openUrl(
            'https://oliverbytes.gumroad.com/affiliates',
          ),
        ),
        if (!GetPlatform.isMobile) ...[
          ListTile(
            leading: Icon(Iconsax.forward_square_outline, color: themeColor),
            title: Text('Share ${appConfig.name} to a friend'),
            onTap: () => Share.share(
              '${appConfig.name} - ${'slogan'.tr}',
              subject: appConfig.name,
            ),
          ),
        ],
        ListTile(
          leading: Icon(LineAwesome.twitter, color: themeColor),
          title: Text('${'follow'.tr} @Liso_Vault'),
          onTap: () => Utils.openUrl(links.twitter),
        ),
        ListTile(
          leading: Icon(LineAwesome.twitter, color: themeColor),
          title: Text('${'follow'.tr} @oliverbytes'),
          subtitle: Text('Indie Developer of ${appConfig.name}'),
          onTap: () => Utils.openUrl(kOliverTwitterUrl),
        ),
        // ContextMenuButton(
        //   controller.developerMenuItems,
        //   useMouseRegion: true,
        //   padding: EdgeInsets.zero,
        //   child: ListTile(
        //     leading: Icon(Iconsax.code, color: themeColor),
        //     title: Text('developer'.tr),
        //
        //     onTap: () {},
        //   ),
        // ),
        const Divider(),
        ListTile(
          leading: RemoteImage(
            url: 'https://i.imgur.com/0H0sWlN.png',
            width: 20,
            failWidget: Image.asset(Images.placeholder, height: 20),
          ),
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
              failWidget: Image.asset(Images.placeholder, height: 20),
            ),
          ),
          title: const Text('NexSnap Screenshot Editor'),
          subtitle: const Text('Make beautiful screenshots in seconds'),
          onTap: () => Utils.openUrl('https://nexsnap.app'),
        ),
        ListTile(
          leading: RemoteImage(
            url:
                'https://tools.applemediaservices.com/api/artwork/US/app/6448982120.png',
            width: 20,
            failWidget: Image.asset(Images.placeholder, height: 20),
          ),
          title: const Text('NexTran'),
          subtitle: Text('nextran_desc'.tr),
          onTap: () => Utils.openUrl(
            isApple && CoreConfig().isAppStore
                ? 'https://apps.apple.com/us/app/nexbot-ai-writing-assistant/id6448982120'
                : 'https://nextran.app',
          ),
        ),
        ListTile(
          leading: Icon(LineAwesome.globe_solid, color: themeColor),
          title: Text('help_translate'.tr),
          onTap: () => Utils.openUrl(links.translations),
        ),
        ListTile(
          leading: Icon(Iconsax.people_outline, color: themeColor),
          title: const Text('Contributors'),
          subtitle: const Text('Thanks to these people'),
          onTap: () => Utils.openUrl(links.contributors),
        ),
        ListTile(
          leading: Icon(Iconsax.code_1_outline, color: themeColor),
          title: Text('licenses'.tr),
          onTap: () => controller.showLicenses(context),
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
