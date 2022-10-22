import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/middlewares/authentication.middleware.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/notifications/notifications.manager.dart';
import '../../core/persistence/persistence.dart';
import '../main/main_screen.controller.dart';
import '../supabase/supabase_auth.service.dart';

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
      name: Routes.passwordGenerator,
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
    await SupabaseAuthService.to.signOut(); // just to make sure

    // TODO: improve password validation
    if (passwordController.text.trim() !=
        passwordConfirmController.text.trim()) {
      change(null, status: RxStatus.success());

      // TODO: localize
      UIUtils.showSnackBar(
        title: 'Passwords do not match',
        message: 'Re-enter your passwords',
        icon: const Icon(Iconsax.warning_2, color: Colors.red),
        seconds: 4,
      );

      return console.error('Passwords do not match');
    }

    Persistence.to.backedUpSeed.val =
        Get.parameters['from'] == 'restore_screen';
    Persistence.to.backedUpPassword.val = true;
    final isNewVault = Get.parameters['from'] == 'seed_screen';

    await WalletService.to.create(
      Get.parameters['seed']!,
      passwordController.text.trim(),
      isNewVault,
    );

    change(null, status: RxStatus.success());

    NotificationsManager.notify(
      title:
          'Welcome ${isNewVault ? ' ' : 'back '}to ${ConfigService.to.appName}',
      body: 'Your vault has been ${isNewVault ? 'created' : 'restored'}',
    );

    AuthenticationMiddleware.signedIn = true;
    MainScreenController.to.navigate();
  }
}
