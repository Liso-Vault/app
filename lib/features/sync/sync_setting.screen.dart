import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/styles.dart';
import 'package:liso/features/general/section.widget.dart';

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
      child: SingleChildScrollView(
        child: Container(
          constraints: Styles.containerConstraints,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Icon(LineIcons.cog, size: 100, color: kAppColor),
              const SizedBox(height: 10),
              const Text(
                'Settings',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              const Text(
                "Choose your preferred settings",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Section(
                text: 'Liso Cloud',
                fontSize: 15,
                alignment: CrossAxisAlignment.center,
              ),
              const SizedBox(height: 20),
              SimpleBuilder(
                builder: (context) {
                  return Column(
                    children: <Widget>[
                      RadioListTile<bool>(
                        title: Text('synchronize'.tr),
                        subtitle: const Text(
                          "Keep multiple devices in sync using our Secure Decentralized Cloud Storage powered by Sia",
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
                      CheckboxListTile(
                        title: const Text('Errors & Crashes'),
                        subtitle: const Text(
                          "Help us by sending anonymous crash reports so we can crush those pesky bugs and improve your experience",
                        ),
                        secondary: const Icon(LineIcons.bug),
                        value: PersistenceService.to.crashReporting.val,
                        onChanged: (value) =>
                            PersistenceService.to.crashReporting.val = value!,
                      ),
                      const Divider(),
                      CheckboxListTile(
                        title: const Text('Usage Statistics'),
                        subtitle: const Text(
                          'Help us understand how you use the app so we can improve the app without compromising your privacy.',
                        ),
                        secondary: const Icon(Icons.analytics),
                        value: PersistenceService.to.analytics.val,
                        onChanged: (value) =>
                            PersistenceService.to.analytics.val = value!,
                      ),
                    ],
                  );
                },
              ),
              const Divider(),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  onPressed: save,
                  label: Text('continue'.tr),
                  icon: const Icon(LineIcons.arrowCircleRight),
                ),
              ),
            ],
          ),
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
