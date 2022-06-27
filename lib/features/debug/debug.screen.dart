import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/general/appbar_leading.widget.dart';
import 'package:liso/features/pro/pro.controller.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

import '../../core/firebase/config/config.service.dart';
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
            throw Exception('Test Exception! Release: $kReleaseMode');
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
            // UIUtils.showSimpleDialog(
            //   'Limits',
            //   jsonEncode(ProController.to.limits.toJson()),
            // );

            console
                .wtf('api key: ${ConfigService.to.secrets.revenuecat.apiKey}');
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
