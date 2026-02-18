import 'package:app_core/globals.dart';
import 'package:app_core/purchases/purchases.services.dart';
import 'package:app_core/services/local_auth.service.dart';
import 'package:app_core/services/notifications.service.dart';
import 'package:app_core/utils/utils.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/wallet/wallet.service.dart';

class AppService extends GetxService with ConsoleMixin {
  static AppService get to => Get.find();

  // VARIABLES
  final busy = false.obs;

  // GETTERS

  // INIT

  void onboard() {
    // await PurchasesService.to.show(cooldown: 10);
    // UIUtils.requestReview();

    showModalBottomSheet(
      context: Get.context!,
      enableDrag: false,
      builder: (context) {
        return Obx(
          () => Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 36.0,
              horizontal: 24.0,
            ),
            child: Visibility(
              visible: !busy.value,
              replacement: const Center(child: CircularProgressIndicator()),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'welcome'.tr,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'benefit_main'.tr,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: create,
                          icon: const Icon(Icons.add),
                          label: Text('create_vault'.tr),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: restore,
                          icon: const Icon(Icons.undo),
                          label: Text('restore_vault'.tr),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void create() async {
    await PurchasesService.to.show(cooldown: 10);
    busy.value = true;

    if (!isLocalAuthSupported) {
      busy.value = false;
      return Utils.adaptiveRouteOpen(name: AppRoutes.seed);
    }

    final authenticated = await LocalAuthService.to.authenticate(
      subTitle: 'create_your_vault'.tr,
      body: 'authenticate_to_verify_and_approve_this_action'.tr,
    );

    if (!authenticated) {
      busy.value = false;
      return;
    }

    final seed = bip39.generateMnemonic(strength: 256);
    final password = AppUtils.generatePassword();
    await WalletService.to.create(seed, password, true);
    busy.value = false;
    Get.closeOverlay();

    NotificationsService.to.notify(
      title: 'welcome'.tr,
      body: 'your_vault_has_been_created'.tr,
    );
  }

  void restore() {
    Get.closeOverlay();
    Utils.adaptiveRouteOpen(name: AppRoutes.restore);
  }
}
