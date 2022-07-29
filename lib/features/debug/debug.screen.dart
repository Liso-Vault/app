import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/firebase/config/models/config_app.model.dart';
import 'package:liso/core/firebase/firestore.service.dart';
import 'package:liso/core/firebase/functions.service.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/general/appbar_leading.widget.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

import '../../core/firebase/auth_desktop.service.dart';
import '../../core/firebase/model/user.model.dart';
import '../../core/hive/models/metadata/app.hive.dart';
import '../../core/hive/models/metadata/device.hive.dart';
import '../../core/liso/liso.manager.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/utils.dart';
import '../app/routes.dart';
import '../joined_vaults/joined_vault.controller.dart';
import '../pro/pro.controller.dart';
import '../shared_vaults/shared_vault.controller.dart';

class DebugScreen extends StatelessWidget with ConsoleMixin {
  const DebugScreen({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Firebase Auth'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () async {
            AuthDesktopService.to.signIn();
          },
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Get Remote Config'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () async {
            final result = await FunctionsService.to.getRemoteConfig();

            result.fold(
              (error) => console.error(error),
              (response) {
                console.info(
                    'response: ${response.parameters.secretsConfig.toJson()}');
              },
            );
          },
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Get User'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () async {
            final result = await FunctionsService.to.getUser(
              AuthService.to.userId,
            );

            result.fold(
              (error) => console.error(error),
              (response) {
                console.info('response: ${response.toJson()}');
              },
            );
          },
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Set User'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () async {
            AuthService.to.record();
          },
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Purchaser Info'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () async {
            final dateString = DateTime.now().toIso8601String();

            ProController.to.info.value.entitlements.all.addAll(
              {
                'pro': EntitlementInfo(
                  'pro-sub-annual',
                  true,
                  true,
                  dateString,
                  dateString,
                  'pro-sub-annual',
                  false,
                  ownershipType: OwnershipType.purchased,
                  store: Store.playStore,
                  expirationDate: dateString,
                  unsubscribeDetectedAt: dateString,
                  billingIssueDetectedAt: dateString,
                )
              },
            );

            console.info(
                'isPro: ${ProController.to.isPro}, isFreeTrial: ${ProController.to.isFreeTrial}\npurchaser: ${ProController.to.info.value.toJson()}');
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
              jsonEncode(ProController.to.limits.toJson()),
            );
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
