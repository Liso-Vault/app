import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/firebase/auth_desktop.service.dart';
import '../../core/middlewares/authentication.middleware.dart';
import '../../core/utils/globals.dart';
import '../general/appbar_leading.widget.dart';
import '../joined_vaults/joined_vault.controller.dart';
import '../shared_vaults/shared_vault.controller.dart';
import 'debug_screen.controller.dart';

class DebugScreen extends StatelessWidget with ConsoleMixin {
  const DebugScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DebugScreenController());

    final content = ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Save Info'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: controller.saveInfo,
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Set Autofill Service'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: controller.setAutofillService,
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Set Preferences'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: controller.setPreferences,
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Result with Datasets'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: controller.datasets,
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Result Dataset'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: controller.dataset,
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Save Complete'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: controller.save,
        ),
        const Divider(),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Auth Sign Out'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () async {
            AuthDesktopService.to.signOut();
          },
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Auth Sign In'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () async {
            AuthDesktopService.to.signIn();
          },
        ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Sign Out'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () async {
            AuthenticationMiddleware.signedIn = false;
          },
        ),
        // ListTile(
        //   leading: Icon(Iconsax.code, color: themeColor),
        //   title: const Text('Get Remote Config'),
        //   trailing: const Icon(Iconsax.arrow_right_3),
        //   onTap: () async {
        //     final result = await FunctionsService.to.getRemoteConfig();

        //     result.fold(
        //       (error) => console.error(error),
        //       (response) {
        //         console.info(
        //             'response: ${response.parameters.secretsConfig.toJson()}');
        //       },
        //     );
        //   },
        // ),
        // ListTile(
        //   leading: Icon(Iconsax.code, color: themeColor),
        //   title: const Text('Get User'),
        //   trailing: const Icon(Iconsax.arrow_right_3),
        //   onTap: () async {
        //     final result = await FunctionsService.to.getUser(
        //       AuthService.to.userId,
        //     );

        //     result.fold(
        //       (error) => console.error(error),
        //       (response) {
        //         console.info('response: ${response.toJson()}');
        //       },
        //     );
        //   },
        // ),
        // ListTile(
        //   leading: Icon(Iconsax.code, color: themeColor),
        //   title: const Text('Set User'),
        //   trailing: const Icon(Iconsax.arrow_right_3),
        //   onTap: () async {
        //     AuthService.to.record();
        //   },
        // ),
        // ListTile(
        //   leading: Icon(Iconsax.code, color: themeColor),
        //   title: const Text('Purchaser Info'),
        //   trailing: const Icon(Iconsax.arrow_right_3),
        //   onTap: () async {
        //     final dateString = DateTime.now().toIso8601String();

        //     ProController.to.info.value.entitlements.all.addAll(
        //       {
        //         'pro': EntitlementInfo(
        //           'pro-sub-annual',
        //           true,
        //           true,
        //           dateString,
        //           dateString,
        //           'pro-sub-annual',
        //           false,
        //           ownershipType: OwnershipType.purchased,
        //           store: Store.playStore,
        //           expirationDate: dateString,
        //           unsubscribeDetectedAt: dateString,
        //           billingIssueDetectedAt: dateString,
        //         )
        //       },
        //     );

        //     console.info(
        //         'isPro: ${ProController.to.isPro}, isFreeTrial: ${ProController.to.isFreeTrial}\npurchaser: ${ProController.to.info.value.toJson()}');
        //   },
        // ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Restart Vault Controllers'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () async {
            SharedVaultsController.to.restart();
            JoinedVaultsController.to.restart();
          },
        ),
        // ListTile(
        //   leading: Icon(Iconsax.code, color: themeColor),
        //   title: const Text('Show Limits'),
        //   trailing: const Icon(Iconsax.arrow_right_3),
        //   onTap: () async {
        //     UIUtils.showSimpleDialog(
        //       'Limits',
        //       jsonEncode(ProController.to.limits.toJson()),
        //     );
        //   },
        // ),
        // ListTile(
        //   leading: Icon(Iconsax.code, color: themeColor),
        //   title: const Text('Wallet Connect'),
        //   trailing: const Icon(Iconsax.arrow_right_3),
        //   onTap: _walletConnect,
        // ),
        // ListTile(
        //   leading: Icon(Iconsax.code, color: themeColor),
        //   title: const Text('Export Vault JSON'),
        //   trailing: const Icon(Iconsax.arrow_right_3),
        //   onTap: () async {
        //     final json = await LisoManager.compactJson();
        //     console.warning(json);
        //   },
        // ),
        ListTile(
          leading: Icon(Iconsax.code, color: themeColor),
          title: const Text('Generate Key'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: () {
            console.wtf(base64Encode(Hive.generateSecureKey()));
          },
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
