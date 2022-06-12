import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/wallet/wallet.service.dart';

import '../../core/firebase/auth.service.dart';

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
    await AuthService.to.signOut(); // just to make sure

    // TODO: improve password validation
    if (passwordController.text != passwordConfirmController.text) {
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

    change(null, status: RxStatus.success());
    final isNewVault = Get.parameters['from'] == 'seed_screen';

    await WalletService.to.create(
      Get.parameters['seed']!,
      passwordController.text,
      isNewVault,
    );

    Get.offNamedUntil(Routes.main, (route) => false);
  }
}
