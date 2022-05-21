import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/general/appbar_leading.widget.dart';
import 'package:liso/features/general/section.widget.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/notifications/notifications.manager.dart';
import '../../core/services/persistence.service.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';

class ConfigurationScreen extends StatelessWidget with ConsoleMixin {
  const ConfigurationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fromSettings = Get.parameters['from'] == 'settings';
    final persistence = Get.find<PersistenceService>();

    void _continue() {
      NotificationsManager.notify(
        title: 'Welcome to ${ConfigService.to.appName}', // TODO: localize
        body: ConfigService.to.general.app.shortDescription,
      );

      persistence.syncConfirmed.val = true;
      Get.offNamedUntil(Routes.main, (route) => false);
    }

    final syncOptions = SimpleBuilder(
      builder: (context) {
        final isSia = persistence.syncProvider.val == LisoSyncProvider.sia.name;
        final isIPFS =
            persistence.syncProvider.val == LisoSyncProvider.ipfs.name;
        final isStorj =
            persistence.syncProvider.val == LisoSyncProvider.storj.name;
        final isSkyNet =
            persistence.syncProvider.val == LisoSyncProvider.skynet.name;
        final isCustom =
            persistence.syncProvider.val == LisoSyncProvider.custom.name;

        String providerName = '', providerDescription = '', providerUrl = '';

        if (isSia) {
          providerName = 'Sia';
          providerDescription =
              'Sia is an open source decentralized storage network that leverages blockchain technology to create a secure and redundant cloud storage platform.';
          providerUrl = 'https://sia.tech/';
        } else if (isIPFS) {
          providerName = 'IPFS';
          providerDescription =
              'InterPlanetary File System, or IPFS, is a distributed and decentralized storage network for storing and accessing files, websites, data, and applications. IPFS uses peer-to-peer network technology to connect a series of nodes located across the world that make up the IPFS network.';
          providerUrl = 'https://ipfs.io/';
        } else if (isStorj) {
          providerName = 'Storj';
          providerDescription =
              'Storj is an open source decentralized cloud storage network. Filebase integrates natively with the Storj, allowing for a simple and affordable way to upload your data onto the Storj network.';
          providerUrl = 'https://storj.io/';
        } else if (isSkyNet) {
          providerName = 'SkyNet';
          providerDescription =
              'Skynet is a decentralized storage platform that leverages the Sia network. This technology is built for high availability, scalability, and easy file sharing.';
          providerUrl = 'https://skynetlabs.com/';
        } else if (isCustom) {
          providerName = 'Custom';
          providerDescription =
              'Configure using your own S3 compatible cloud storage provider.';
          // TODO: change to Custom Sync Provider guide page
          providerUrl = ConfigService.to.general.app.links.website;
        }

        final syncChild = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: 'Keep multiple devices in sync',
                style:
                    DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
                children: [
                  const TextSpan(
                    text: ' via a secure & decentralized cloud storage',
                  ),
                  if (fromSettings) ...[
                    TextSpan(
                      text: ': $providerName',
                      style: TextStyle(color: themeColor),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => launchUrlString(providerUrl),
                    ),
                  ]
                ],
              ),
            ),
            if (persistence.sync.val) ...[
              const Divider(),
              const Text('Choose a provider'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  ChoiceChip(
                    label: const Text('IPFS'),
                    selected: isIPFS,
                    avatar: isIPFS ? const Icon(Icons.check) : null,
                    onSelected: (value) => persistence.syncProvider.val =
                        LisoSyncProvider.ipfs.name,
                  ),
                  ChoiceChip(
                    label: const Text('SkyNet'),
                    selected: isSkyNet,
                    avatar: isSkyNet ? const Icon(Icons.check) : null,
                    onSelected: (value) => persistence.syncProvider.val =
                        LisoSyncProvider.skynet.name,
                  ),
                  ChoiceChip(
                    label: const Text('Sia'),
                    selected: isSia,
                    avatar: isSia ? const Icon(Icons.check) : null,
                    onSelected: (value) => persistence.syncProvider.val =
                        LisoSyncProvider.sia.name,
                  ),
                  ChoiceChip(
                    label: const Text('Storj'),
                    selected: isStorj,
                    avatar: isStorj ? const Icon(Icons.check) : null,
                    onSelected: (value) => persistence.syncProvider.val =
                        LisoSyncProvider.storj.name,
                  ),
                  ChoiceChip(
                    label: const Text('Custom'),
                    selected: isCustom,
                    avatar: isCustom ? const Icon(Icons.check) : null,
                    onSelected: (value) => Utils.adaptiveRouteOpen(
                      name: Routes.syncProvider,
                      parameters: {'from': 'settings'},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: providerDescription,
                  style:
                      DefaultTextStyle.of(context).style.copyWith(fontSize: 12),
                  children: [
                    TextSpan(
                      text: ' Learn more',
                      style: TextStyle(color: themeColor),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => launchUrlString(providerUrl),
                    ),
                  ],
                ),
              ),
            ]
          ],
        );

        return Column(
          children: <Widget>[
            RadioListTile<bool>(
              dense: true,
              title: Text('synchronize'.tr),
              subtitle: syncChild,
              secondary: const Icon(Iconsax.cloud_change),
              value: true,
              groupValue: persistence.sync.val,
              onChanged: (value) => persistence.sync.val = value!,
            ),
            const Divider(),
            RadioListTile<bool>(
              dense: true,
              title: Text('offline'.tr),
              subtitle: const Text(
                'Manually import/export offline vaults across your devices',
              ),
              secondary: const Icon(Icons.wifi_off),
              value: false,
              groupValue: persistence.sync.val,
              onChanged: (value) => persistence.sync.val = value!,
            ),
          ],
        );
      },
    );

    final content = Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: Styles.containerConstraints,
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Icon(Iconsax.setting_3, size: 100, color: themeColor),
              const SizedBox(height: 10),
              const Text(
                'Configuration',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              const Text(
                "Choose your preferred configuration",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const Divider(height: 20),
              const Section(
                text: 'Liso Cloud Sync',
                fontSize: 15,
                alignment: CrossAxisAlignment.center,
              ),
              const SizedBox(height: 20),
              syncOptions,
              const Divider(),
              const Section(
                text: 'Anonymous Reporting',
                fontSize: 15,
                alignment: CrossAxisAlignment.center,
              ),
              const SizedBox(height: 20),
              SimpleBuilder(
                builder: (context) {
                  return Column(
                    children: <Widget>[
                      SwitchListTile(
                        dense: true,
                        title: const Text('Errors & Crashes'),
                        secondary: Icon(
                          Iconsax.cpu,
                          color: themeColor,
                        ),
                        value: persistence.crashReporting.val,
                        subtitle: const Text(
                          "Help us by sending anonymous crash reports so we can crush those pesky bugs and improve your experience",
                        ),
                        onChanged: (value) =>
                            persistence.crashReporting.val = value,
                      ),
                      const Divider(),
                      SwitchListTile(
                        dense: true,
                        title: const Text('Usage Statistics'),
                        secondary: Icon(
                          Iconsax.chart_square,
                          color: themeColor,
                        ),
                        value: persistence.analytics.val,
                        subtitle: const Text(
                          'Help us understand how you use the app so we can improve the app without compromising your privacy.',
                        ),
                        onChanged: (value) => persistence.analytics.val = value,
                      ),
                    ],
                  );
                },
              ),
              const Divider(),
              if (!fromSettings) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: _continue,
                    label: Text('continue'.tr),
                    icon: const Icon(Iconsax.arrow_circle_right),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () => Future.value(fromSettings),
      child: Scaffold(
        appBar: fromSettings
            ? AppBar(
                leading: const AppBarLeadingButton(),
              )
            : null,
        body: content,
      ),
    );
  }
}
