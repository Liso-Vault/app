import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/utils.dart';

import '../general/appbar_leading.widget.dart';
import '../general/busy_indicator.widget.dart';
import 'ipfs_screen.controller.dart';

class IPFSScreen extends GetWidget<IPFSScreenController> with ConsoleMixin {
  const IPFSScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final persistence = Get.find<PersistenceService>();

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Form(
        key: controller.formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.ipfsUrlController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (data) => Utils.validateUri(data!),
                    decoration: InputDecoration(
                      labelText: 'server_url'.tr,
                      hintText: 'http://127.0.0.1:5001',
                    ),
                  ),
                ),
                Obx(
                  () => Visibility(
                    visible: !controller.ipfsBusy(),
                    child: IconButton(
                      onPressed: controller.checkIPFS,
                      icon: const Icon(LineIcons.vial),
                    ),
                    replacement: const BusyIndicator(),
                  ),
                ),
              ],
            ),
            const Divider(),
            SimpleBuilder(
              builder: (_) {
                return SwitchListTile(
                  title: Text('synchronize'.tr),
                  subtitle: Text(
                    persistence.ipfsSync.val
                        ? 'Synchronization to IPFS is on'
                        : 'Synchronization to IPFS is off',
                  ),
                  secondary: const Icon(LineIcons.syncIcon),
                  value: persistence.ipfsSync.val,
                  onChanged: (value) => persistence.ipfsSync.val = value,
                );
              },
            ),
            const Divider(),
            SimpleBuilder(
              builder: (_) {
                return SwitchListTile(
                  title: Text('instant_sync'.tr),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        persistence.ipfsInstantSync.val
                            ? 'On - Instantly sync on every change you make. Data hungry. Not recommended on a remote server.'
                            : 'Off - Intillegently decide when is the best time to sync. Recommended.',
                      ),
                    ],
                  ),
                  secondary: const Icon(LineIcons.syncIcon),
                  value: persistence.ipfsInstantSync.val,
                  onChanged: persistence.ipfsSync.val
                      ? (value) => persistence.ipfsInstantSync.val = value
                      : null,
                );
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );

    final appBar = AppBar(
      title: Text('IPFS ${'configuration'.tr}'),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
      actions: [
        IconButton(
          onPressed: controller.save,
          icon: const Icon(LineIcons.check),
        ),
      ],
    );

    final body = controller.obx(
      (_) => content,
      onLoading: const BusyIndicator(),
    );

    return Scaffold(
      appBar: appBar,
      body: body,
    );
  }
}
