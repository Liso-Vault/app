import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/styles.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/services/persistence.service.dart';
import '../../core/utils/globals.dart';
import '../app/routes.dart';

class SyncSettingScreen extends StatelessWidget with ConsoleMixin {
  const SyncSettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void save() {
      final persistence = Get.find<PersistenceService>();
      persistence.syncConfirmed.val = true;
      Get.offNamedUntil(Routes.main, (route) => false);
    }

    final content = Center(
      child: Container(
        constraints: Styles.containerConstraints,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LineIcons.memory, size: 100, color: kAppColor),
            const Text(
              'Vault Management',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 15),
            const Text(
              "Choose your preferred vault management feature",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Divider(),
            SimpleBuilder(
              builder: (context) {
                return Column(
                  children: <Widget>[
                    RadioListTile<bool>(
                      title: Text('${ConfigService.to.appName} Cloud Sync'),
                      subtitle: const Text(
                        "Securely keep multiple devices in sync in a decentralized cloud storage",
                      ),
                      secondary: const Icon(LineIcons.cloud),
                      value: true,
                      groupValue: PersistenceService.to.sync.val,
                      onChanged: (value) =>
                          PersistenceService.to.sync.val = value!,
                    ),
                    const Divider(),
                    RadioListTile<bool>(
                      title: Text('offline'.tr),
                      subtitle: const Text(
                        'Manually import/export offline vaults across your devices',
                      ),
                      secondary: const Icon(Icons.wifi_off),
                      value: false,
                      groupValue: PersistenceService.to.sync.val,
                      onChanged: (value) =>
                          PersistenceService.to.sync.val = value!,
                    ),
                  ],
                );
              },
            ),
            const Divider(),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: save,
              label: Text('continue'.tr),
              icon: const Icon(LineIcons.arrowCircleRight),
            ),
          ],
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        appBar: null,
        body: content,
      ),
    );
  }
}
