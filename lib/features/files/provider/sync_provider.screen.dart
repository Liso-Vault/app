import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/general/appbar_leading.widget.dart';

import '../../../core/persistence/persistence.dart';
import '../../../core/persistence/persistence_builder.widget.dart';
import '../../../core/utils/globals.dart';
import '../../../core/utils/utils.dart';
import '../../../resources/resources.dart';
import '../../app/routes.dart';
import '../../general/section.widget.dart';

class SyncProviderScreen extends StatelessWidget with ConsoleMixin {
  const SyncProviderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final persistence = Get.find<Persistence>();

    void switchProvider(LisoSyncProvider? provider) {
      void confirm() {
        if (provider != LisoSyncProvider.custom) {
          persistence.syncProvider.val = provider!.name;
          // return SyncService.to.init();
        }

        // custom
        Utils.adaptiveRouteOpen(
          name: Routes.customSyncProvider,
          parameters: {'from': 'settings'},
        );
      }

      if (!AuthService.to.isSignedIn) return confirm();

      UIUtils.showSimpleDialog(
        'Switch Sync Provider',
        'Are you sure you want to switch to ${provider!.name.toUpperCase()} as the Sync Provider?\n\nUnexpected side effects might happen like inconsistent files and vault data.',
        closeText: 'Cancel',
        actionText: 'Switch',
        action: () {
          Get.back(); // close dialog
          confirm();
        },
      );
    }

    final providersMap = {
      LisoSyncProvider.sia.name: {
        "name": "Sia",
        "description":
            "Sia is an open source decentralized storage network that leverages blockchain technology to create a secure and redundant cloud storage platform.",
        "image": Images.sia,
        "url": "https://sia.tech/",
      },
      // LisoSyncProvider.storj.name: {
      //   "name": "Storj",
      //   "description":
      //       "Storj is an open source decentralized cloud storage network. Filebase integrates natively with the Storj, allowing for a simple and affordable way to upload your data onto the Storj network.",
      //   "image": Images.storj,
      //   "url": "https://storj.io/",
      // },
      // LisoSyncProvider.ipfs.name: {
      //   "name": "IPFS",
      //   "description":
      //       "InterPlanetary File System, or IPFS, is a distributed and decentralized storage network for storing and accessing files, websites, data, and applications. IPFS uses peer-to-peer network technology to connect a series of nodes located across the world that make up the IPFS network.",
      //   "image": Images.ipfs,
      //   "url": "https://ipfs.io/",
      // },
      // LisoSyncProvider.skynet.name: {
      //   "name": "Skynet",
      //   "description":
      //       "Skynet is a decentralized storage platform that leverages the Sia network. This technology is built for high availability, scalability, and easy file sharing.",
      //   "image": Images.skynet,
      //   "url": "https://skynetlabs.com/",
      // },
    };

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: PersistenceBuilder(builder: (p, context) {
        final provider = providersMap[p.newSyncProvider];

        final name = provider?['name'];
        final description = provider?['description'];
        final image = provider?['image'];
        final url = provider?['url'];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (p.newSyncProvider != LisoSyncProvider.custom.name) ...[
              Image.asset(image!, height: 150),
              const SizedBox(height: 20),
              Text(
                name!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(height: 15),
              OutlinedButton(
                onPressed: () => Utils.openUrl(url!),
                child: const Text('Learn more'),
              ),
            ] else ...[
              const Icon(Iconsax.setting_2, size: 100),
              const SizedBox(height: 20),
              const Text(
                'Custom',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 10),
              const Text(
                'Set your own configuration',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              TextButton(
                onPressed: () => Utils.adaptiveRouteOpen(
                  name: Routes.customSyncProvider,
                ),
                child: const Text('Configure'),
              ),
            ],
            Section(text: 'Choose a provider'.toUpperCase()),
            RadioListTile<LisoSyncProvider>(
              title: const Text('Sia'),
              secondary: Image.asset(Images.sia, height: 25),
              value: LisoSyncProvider.sia,
              groupValue: LisoSyncProvider.values.byName(p.newSyncProvider),
              onChanged: switchProvider,
            ),
            // RadioListTile<LisoSyncProvider>(
            //   title: const Text('Storj'),
            //   secondary: Image.asset(Images.storj, height: 25),
            //   value: LisoSyncProvider.storj,
            //   groupValue: LisoSyncProvider.values.byName(p.syncProvider.val),
            //   onChanged: _switchProvider,
            // ),
            // RadioListTile<LisoSyncProvider>(
            //   title: const Text('IPFS'),
            //   secondary: Image.asset(Images.ipfs, height: 25),
            //   value: LisoSyncProvider.ipfs,
            //   groupValue: LisoSyncProvider.values.byName(p.syncProvider.val),
            //   onChanged: _switchProvider,
            // ),
            // RadioListTile<LisoSyncProvider>(
            //   title: const Text('Skynet'),
            //   secondary: Image.asset(Images.skynet, height: 25),
            //   value: LisoSyncProvider.skynet,
            //   groupValue: LisoSyncProvider.values.byName(p.syncProvider.val),
            //   onChanged: _switchProvider,
            // ),
            RadioListTile<LisoSyncProvider>(
              title: const Text('Custom'),
              secondary: const Icon(Iconsax.setting_2),
              value: LisoSyncProvider.custom,
              groupValue: LisoSyncProvider.values.byName(p.newSyncProvider),
              onChanged: switchProvider,
            ),
          ],
        );
      }),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Sync Provider'),
        leading: const AppBarLeadingButton(),
        actions: [
          TextButton(
            onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
            child: const Text('Need Help ?'),
          ),
        ],
      ),
      body: content,
    );
  }
}
