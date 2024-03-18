import 'package:app_core/config/app.model.dart';
import 'package:app_core/services/notifications.service.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../core/persistence/persistence.dart';

class CreatePasswordScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  // PROPERTIES
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  // FUNCTIONS

  void generate() async {
    final password_ = await Utils.adaptiveRouteOpen(
      name: AppRoutes.passwordGenerator,
      parameters: {'return': 'true'},
    );

    if (password_ == null) return;
    console.wtf('password: $password_');
    // show
    obscurePassword.value = false;
    obscureConfirmPassword.value = false;
    // inject
    passwordController.text = password_;
    passwordConfirmController.text = password_;
  }

  void confirm() async {
    if (!formKey.currentState!.validate()) return;
    if (status == RxStatus.loading()) return console.error('still busy');
    change(null, status: RxStatus.loading());

    // TODO: improve password validation
    if (passwordController.text.trim() !=
        passwordConfirmController.text.trim()) {
      change(null, status: RxStatus.success());

      // TODO: localize
      UIUtils.showSnackBar(
        title: 'Passwords do not match',
        message: 'Re-enter your passwords',
        icon: const Icon(Iconsax.warning_2_outline, color: Colors.red),
        seconds: 4,
      );

      return console.error('Passwords do not match');
    }

    AppPersistence.to.backedUpPassword.val = true;
    AppPersistence.to.backedUpSeed.val = Get.previousRoute == AppRoutes.restore;
    final isNewVault = Get.previousRoute == AppRoutes.seed;

    await WalletService.to.create(
      generatedSeed,
      passwordController.text.trim(),
      isNewVault,
    );

    change(null, status: RxStatus.success());

    NotificationsService.to.notify(
      title: 'Welcome ${isNewVault ? ' ' : 'back '}to ${appConfig.name}',
      body: 'Your vault has been ${isNewVault ? 'created' : 'restored'}',
    );
  }
}
