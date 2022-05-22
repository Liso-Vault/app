import 'package:console_mixin/console_mixin.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/utils/globals.dart';

import '../../core/firebase/config/config.service.dart';
import '../../resources/resources.dart';
import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import '../general/remote_image.widget.dart';
import 'upgrade_screen.controller.dart';

class UpgradeScreen extends GetView<UpgradeScreenController> with ConsoleMixin {
  const UpgradeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final title = Get.parameters['title']!;
    // final body = Get.parameters['body']!;

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon(LineIcons.rocket, size: 150, color: themeColor),
          // const SizedBox(height: 10),
          // Text(
          //   '${ConfigService.to.appName} Pro',
          //   style: const TextStyle(fontSize: 30),
          // ),
          // const SizedBox(height: 15),
          // Text(
          //   title,
          //   textAlign: TextAlign.center,
          //   style: const TextStyle(fontSize: 17),
          // ),
          // const SizedBox(height: 10),
          // Text(
          //   body,
          //   textAlign: TextAlign.center,
          //   style: const TextStyle(color: Colors.grey),
          // ),
          // const SizedBox(height: 30),
          // SizedBox(
          //   width: 200,
          //   child: ElevatedButton(
          //     onPressed: () {
          //       UIUtils.showSimpleDialog(
          //         'Upgrade to ${ConfigService.to.appName} Pro',
          //         'This feature is coming soon',
          //       );
          //     },
          //     child: const Text('Subscribe'),
          //   ),
          // ),

          Text(
            'Features',
            style: TextStyle(fontSize: 20, color: themeColor),
          ),
          const SizedBox(height: 20),
          Obx(
            () {
              final tier = controller.tierSetting;

              return Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: const Icon(Iconsax.coin),
                      title: const Text('Token Threshold'),
                      onTap: () {},
                      trailing: Text(
                        '${tier.tokenThreshold}',
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.document_cloud),
                      title: const Text('Max Storage Size'),
                      onTap: () {},
                      trailing: Text(
                        filesize(tier.storageSize),
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.weight),
                      title: const Text('Max File Upload Size'),
                      onTap: () {},
                      trailing: Text(
                        filesize(tier.uploadSize),
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.weight),
                      title: const Text('Max Items'),
                      onTap: () {},
                      trailing: Text(
                        '${tier.items}',
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.weight),
                      title: const Text('Max Files'),
                      onTap: () {},
                      trailing: Text(
                        '${tier.files}',
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.weight),
                      title: const Text('Max Backups'),
                      onTap: () {},
                      trailing: Text(
                        '${tier.backups}',
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.weight),
                      title: const Text('Max Devices'),
                      onTap: () {},
                      trailing: Text(
                        '${tier.devices}',
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.weight),
                      title: const Text('Trash Due Days'),
                      onTap: () {},
                      trailing: Text(
                        '${tier.trashDays}',
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.weight),
                      title: const Text('Max Protected Items'),
                      onTap: () {},
                      trailing: Text(
                        '${tier.protectedItems}',
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.weight),
                      title: const Text('Max Shared Users'),
                      onTap: () {},
                      trailing: Text(
                        '${tier.sharedAddresses}',
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                    ),
                    CheckboxListTile(
                      value: tier.addVaults,
                      secondary: const Icon(Iconsax.document_cloud),
                      title: const Text('Custom Vaults'),
                      onChanged: (_) {},
                    ),
                    CheckboxListTile(
                      value: tier.fileEncryption,
                      secondary: const Icon(Iconsax.weight),
                      title: const Text('File Encryption'),
                      onChanged: (_) {},
                    ),
                    CheckboxListTile(
                      value: tier.breachScanner,
                      secondary: const Icon(Iconsax.document_cloud),
                      title: const Text('Breach Scanner'),
                      onChanged: (_) {},
                    ),
                    CheckboxListTile(
                      value: tier.passwordHealth,
                      secondary: const Icon(Iconsax.weight),
                      title: const Text('Password Health'),
                      onChanged: (_) {},
                    ),
                    CheckboxListTile(
                      value: tier.nfcKeycard,
                      secondary: const Icon(Iconsax.document_cloud),
                      title: const Text('NFC Keycard'),
                      onChanged: (_) {},
                    ),
                    CheckboxListTile(
                      value: tier.cipherTool,
                      secondary: const Icon(Iconsax.weight),
                      title: const Text('Cipher Tool'),
                      onChanged: (_) {},
                    ),
                    CheckboxListTile(
                      value: tier.otpGenerator,
                      secondary: const Icon(Iconsax.document_cloud),
                      title: const Text('OTP Generator'),
                      onChanged: (_) {},
                    ),
                    CheckboxListTile(
                      value: tier.prioritySupport,
                      secondary: const Icon(Iconsax.weight),
                      title: const Text('Priority Support'),
                      onChanged: (_) {},
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          TabBar(
            onTap: (index) => controller.tabIndex.value = index,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                color: Get.theme.buttonTheme.colorScheme!.primary,
              ),
            ),
            tabs: const [
              Tab(text: 'Free'),
              Tab(text: 'Tier 1'),
              Tab(text: 'Tier 2'),
              Tab(text: 'Tier 3'),
            ],
          ),
        ],
      ),
    );

    final appBar = AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RemoteImage(
            url: ConfigService.to.general.app.image,
            height: 20,
            placeholder: Image.asset(Images.logo, height: 20),
          ),
          const SizedBox(width: 10),
          Text('${ConfigService.to.appName} Pro',
              style: const TextStyle(fontSize: 20)),
        ],
      ),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
    );

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: appBar,
        body: controller.obx(
          (_) => content,
          onLoading: const BusyIndicator(),
        ),
      ),
    );
  }
}
