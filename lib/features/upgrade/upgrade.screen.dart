import 'package:console_mixin/console_mixin.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';

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
      padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                      leading: const Icon(Iconsax.document),
                      title: const Text('Max Items'),
                      onTap: () {},
                      trailing: Text(
                        '${tier.items}',
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.document_1),
                      title: const Text('Max Files'),
                      onTap: () {},
                      trailing: Text(
                        '${tier.files}',
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.import),
                      title: const Text('Max Backups'),
                      onTap: () {},
                      trailing: Text(
                        '${tier.backups}',
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.cpu),
                      title: const Text('Max Devices'),
                      onTap: () {},
                      trailing: Text(
                        '${tier.devices}',
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.trash),
                      title: const Text('Max Trash Due Days'),
                      onTap: () {},
                      trailing: Text(
                        '${tier.trashDays}',
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.shield_tick),
                      title: const Text('Max Protected Items'),
                      onTap: () {},
                      trailing: Text(
                        '${tier.protectedItems}',
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.people),
                      title: const Text('Max Shared Vault Members'),
                      onTap: () {},
                      trailing: Text(
                        '${tier.sharedMembers}',
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.briefcase),
                      title: const Text('Custom Vaults'),
                      trailing: Text(
                        '${tier.customVaults}',
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Iconsax.key),
                      title: const Text('Encrypted Files'),
                      trailing: Text(
                        '${tier.encryptedFiles}',
                        style: TextStyle(color: themeColor, fontSize: 20),
                      ),
                      onTap: () {},
                    ),
                    ListTile(
                      trailing: Icon(
                        tier.breachScanner ? LineIcons.check : LineIcons.times,
                        color: tier.breachScanner ? themeColor : Colors.red,
                      ),
                      leading: const Icon(Iconsax.scan),
                      title: const Text('Breach Scanner'),
                      onTap: () {},
                    ),
                    ListTile(
                      trailing: Icon(
                        tier.passwordHealth ? LineIcons.check : LineIcons.times,
                        color: tier.passwordHealth ? themeColor : Colors.red,
                      ),
                      leading: const Icon(Iconsax.health),
                      title: const Text('Password Health'),
                      onTap: () {},
                    ),
                    ListTile(
                      trailing: Icon(
                        tier.nfcKeycard ? LineIcons.check : LineIcons.times,
                        color: tier.nfcKeycard ? themeColor : Colors.red,
                      ),
                      leading: const Icon(Iconsax.card),
                      title: const Text('NFC Keycard'),
                      onTap: () {},
                    ),
                    ListTile(
                      trailing: Icon(
                        tier.cipherTool ? LineIcons.check : LineIcons.times,
                        color: tier.cipherTool ? themeColor : Colors.red,
                      ),
                      leading: const Icon(Iconsax.security_card),
                      title: const Text('Cipher Tool'),
                      onTap: () {},
                    ),
                    ListTile(
                      trailing: Icon(
                        tier.otpGenerator ? LineIcons.check : LineIcons.times,
                        color: tier.otpGenerator ? themeColor : Colors.red,
                      ),
                      leading: const Icon(Iconsax.password_check),
                      title: const Text('OTP Generator'),
                      onTap: () {},
                    ),
                    ListTile(
                      trailing: Icon(
                        tier.prioritySupport
                            ? LineIcons.check
                            : LineIcons.times,
                        color: tier.prioritySupport ? themeColor : Colors.red,
                      ),
                      leading: const Icon(Iconsax.message_question),
                      title: const Text('Priority Support'),
                      onTap: () {},
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
              Tab(text: 'Holder'),
              Tab(text: 'Staker'),
              Tab(text: 'Pro'),
            ],
          ),
        ],
      ),
    );

    final appBar = AppBar(
      leading: const AppBarLeadingButton(),
      centerTitle: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RemoteImage(
            url: ConfigService.to.general.app.image,
            height: 20,
            placeholder: Image.asset(Images.logo, height: 20),
          ),
          const SizedBox(width: 10),
          Text(
            '${ConfigService.to.appName} Premium',
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(LineIcons.rocket),
          label: const Text('Upgrade'),
          onPressed: () {
            UIUtils.showSimpleDialog(
              'Upgrade to Pro',
              'Coming soon...',
            );
          },
        ),
      ],
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
