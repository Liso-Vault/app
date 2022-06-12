import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/general/appbar_leading.widget.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

import '../../core/hive/hive_items.service.dart';
import '../../core/liso/liso.manager.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../joined_vaults/joined_vault.controller.dart';
import '../shared_vaults/shared_vault.controller.dart';

class DebugScreen extends StatelessWidget with ConsoleMixin {
  const DebugScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void _walletConnect() async {
      // Create a connector
      final connector = WalletConnect(
        bridge: 'https://bridge.walletconnect.org',
        clientMeta: const PeerMeta(
          name: 'WalletConnect',
          description: 'WalletConnect Developer App',
          url: 'https://walletconnect.org',
          icons: [
            'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
          ],
        ),
      );

      // Subscribe to events
      connector.on(
        'connect',
        (session) => console.info('on connect: $session'),
      );

      connector.on(
        'session_update',
        (payload) => console.info('on session_update: $payload'),
      );

      connector.on(
        'disconnect',
        (session) => console.info('on disconnect: $session'),
      );

      console.info(
        'connected: ${connector.connected}, bridgeConnected: ${connector.bridgeConnected}',
      );

      // Create a new session
      if (!connector.connected) {
        final session = await connector.createSession(
          chainId: 4160,
          onDisplayUri: (uri) => console.info(uri),
        );

        console.info('created session: ${session.accounts}');
      }
    }

    final content = ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Debug'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () async {
            // AppSettings.openSecuritySettings();
            // AppSettings.openLockAndPasswordSettings();
            Persistence.to.backedUpSeed.val = false;
          },
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Show Console'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () async {
            // TODO: show console log
          },
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Restart Vault Controllers'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () async {
            SharedVaultsController.to.restart();
            JoinedVaultsController.to.restart();
          },
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Show Limits'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () async {
            UIUtils.showSimpleDialog(
              'Limits',
              jsonEncode(WalletService.to.limits.toJson()),
            );
          },
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Sign Message'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () async {
            final signature = await WalletService.to.sign('liso');
            console.wtf('signature: $signature');
          },
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Wallet Connect'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: _walletConnect,
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Image Dialog'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => UIUtils.showImageDialog(
            Icon(LineIcons.rocket, size: 100, color: themeColor),
            title: 'The Title',
            body:
                'This is the message to be shown. This is the message to be shown. This is the message to be shown. ',
            closeText: 'Close',
            actionText: 'Action',
            action: () {
              console.info('action');
            },
          ),
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Export Vault JSON'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () async {
            final json = await LisoManager.compactJson();
            console.warning(json);
          },
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Upgrade Screen'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () => Utils.adaptiveRouteOpen(
            name: Routes.upgrade,
            parameters: {
              'title': 'Title',
              'body': 'Custom Message',
            },
          ),
        ),
        const Divider(),
        const ChipInput(
          data: [
            'test',
            'two',
            'three',
            'another',
            'this is a long one',
            'moira',
            'hindi',
            'debugging',
          ],
        ),
      ],
    );

    final appBar = AppBar(
      title: const Text('Debugging'),
      centerTitle: false,
      leading: const AppBarLeadingButton(),
    );

    return Scaffold(
      appBar: appBar,
      body: content,
    );
  }
}

class ChipInput extends GetWidget<ChipsInputController> {
  final List<String> data;
  const ChipInput({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data_ = data.obs;

    return Obx(
      () => Wrap(
        spacing: 5,
        runSpacing: 5,
        children: [
          ...data_
              .map(
                (e) => Chip(
                  label: Text(e),
                  onDeleted: () => data_.remove(e),
                ),
              )
              .toList(),
          ActionChip(
            label: const Icon(Iconsax.add_circle5, size: 20),
            onPressed: controller.add,
          )
        ],
      ),
    );
  }
}

class ChipsInputController extends GetxController {
  // VARIABLES
  final textController = TextEditingController();

  // PROPERTIES
  final data = <String>[].obs;

  // FUNCTIONS
  void add() {
    List<String> _query(String query) {
      if (query.isEmpty) return [];

      final usedTags = HiveItemsService.to.data
          .map((e) => e.tags.where((x) => x.isNotEmpty).toList())
          .toSet();

      // include query as a suggested tag
      final Set<String> tags = {query};

      if (usedTags.isNotEmpty) {
        tags.addAll(usedTags.reduce((a, b) => a + b).toSet());
      }

      final filteredTags = tags.where(
        (e) => e.toLowerCase().contains(query.toLowerCase()),
      );

      return filteredTags.toList();
    }

    Widget _itemBuilder(context, index) {
      final tag = data[index];

      return ListTile(
        title: Text(tag),
        onTap: () {
          //
        },
      );
    }

    final textField = TextFormField(
      controller: textController,
      autofocus: true,
      decoration: const InputDecoration(
        labelText: 'Tag',
        hintText: 'Add a tag',
      ),
      onChanged: (value) => data.value = _query(value),
      onFieldSubmitted: (value) {
        //
        Get.back();
      },
    );

    final listView = Expanded(
      child: Obx(
        () => ListView.builder(
          itemCount: data.length,
          itemBuilder: _itemBuilder,
        ),
      ),
    );

    final content = SizedBox(
      height: 300,
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              textField,
              listView,
            ],
          ),
        ),
      ),
    );

    Get.bottomSheet(content);
  }
}
