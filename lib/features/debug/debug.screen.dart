import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/appbar_leading.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../core/utils/globals.dart';
import '../joined_vaults/joined_vault.controller.dart';
import '../shared_vaults/shared_vault.controller.dart';
import 'debug_screen.controller.dart';

class DebugScreen extends StatelessWidget with ConsoleMixin {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DebugScreenController());

    final content = ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        ListTile(
          title: const Text('Welcome Screen'),
          onTap: () async {
            Utils.adaptiveRouteOpen(name: Routes.welcome);
          },
        ),
        ListTile(
          title: const Text('Upgrade Screen'),
          onTap: () async {
            Utils.adaptiveRouteOpen(
              name: Routes.upgrade,
              ignoreUpgradeGuard: false,
            );
          },
        ),
        ListTile(
          leading: Icon(Iconsax.code_outline, color: themeColor),
          title: const Text('Save Info'),
          trailing: const Icon(Iconsax.arrow_right_3_outline),
          onTap: controller.saveInfo,
        ),
        ListTile(
          leading: Icon(Iconsax.code_outline, color: themeColor),
          title: const Text('Set Autofill Service'),
          trailing: const Icon(Iconsax.arrow_right_3_outline),
          onTap: controller.setAutofillService,
        ),
        ListTile(
          leading: Icon(Iconsax.code_outline, color: themeColor),
          title: const Text('Set Preferences'),
          trailing: const Icon(Iconsax.arrow_right_3_outline),
          onTap: controller.setPreferences,
        ),
        ListTile(
          leading: Icon(Iconsax.code_outline, color: themeColor),
          title: const Text('Result with Datasets'),
          trailing: const Icon(Iconsax.arrow_right_3_outline),
          onTap: controller.datasets,
        ),
        ListTile(
          leading: Icon(Iconsax.code_outline, color: themeColor),
          title: const Text('Result Dataset'),
          trailing: const Icon(Iconsax.arrow_right_3_outline),
          onTap: controller.dataset,
        ),
        ListTile(
          leading: Icon(Iconsax.code_outline, color: themeColor),
          title: const Text('Save Complete'),
          trailing: const Icon(Iconsax.arrow_right_3_outline),
          onTap: controller.save,
        ),
        const Divider(),
        // ListTile(
        //   leading: Icon(Iconsax.code, color: themeColor),
        //   title: const Text('Sign Out'),
        //   trailing: const Icon(Iconsax.arrow_right_3_outline),
        //   onTap: () async {
        //     AuthenticationMiddleware.signedIn = false;
        //   },
        // ),
        // ListTile(
        //   leading: Icon(Iconsax.code, color: themeColor),
        //   title: const Text('Get Remote Config'),
        //   trailing: const Icon(Iconsax.arrow_right_3_outline),
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
        //   trailing: const Icon(Iconsax.arrow_right_3_outline),
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
        //   trailing: const Icon(Iconsax.arrow_right_3_outline),
        //   onTap: () async {
        //     AuthService.to.record();
        //   },
        // ),
        // ListTile(
        //   leading: Icon(Iconsax.code, color: themeColor),
        //   title: const Text('Purchaser Info'),
        //   trailing: const Icon(Iconsax.arrow_right_3_outline),
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
        //         'isPro: ${PurchasesService.to.isPremium}, isFreeTrial: ${ProController.to.isFreeTrial}\npurchaser: ${ProController.to.info.value.toJson()}');
        //   },
        // ),
        ListTile(
          leading: Icon(Iconsax.code_outline, color: themeColor),
          title: const Text('Restart Vault Controllers'),
          trailing: const Icon(Iconsax.arrow_right_3_outline),
          onTap: () async {
            SharedVaultsController.to.restart();
            JoinedVaultsController.to.restart();
          },
        ),
        // ListTile(
        //   leading: Icon(Iconsax.code, color: themeColor),
        //   title: const Text('Show Limits'),
        //   trailing: const Icon(Iconsax.arrow_right_3_outline),
        //   onTap: () async {
        //     UIUtils.showSimpleDialog(
        //       'Limits',
        //       jsonEncode(limits.toJson()),
        //     );
        //   },
        // ),
        // ListTile(
        //   leading: Icon(Iconsax.code, color: themeColor),
        //   title: const Text('Wallet Connect'),
        //   trailing: const Icon(Iconsax.arrow_right_3_outline),
        //   onTap: _walletConnect,
        // ),
        // ListTile(
        //   leading: Icon(Iconsax.code, color: themeColor),
        //   title: const Text('Export Vault JSON'),
        //   trailing: const Icon(Iconsax.arrow_right_3_outline),
        //   onTap: () async {
        //     final json = await LisoManager.compactJson();
        //     console.warning(json);
        //   },
        // ),
        ListTile(
          leading: Icon(Iconsax.code_outline, color: themeColor),
          title: const Text('Test Supabase'),
          trailing: const Icon(Iconsax.arrow_right_3_outline),
          onTap: () {
            //
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
