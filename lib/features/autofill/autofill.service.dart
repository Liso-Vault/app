import 'package:console_mixin/console_mixin.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:get/get.dart';
import 'package:liso/core/notifications/notifications.manager.dart';

import '../../core/firebase/config/config.service.dart';

class LisoAutofillService extends GetxService with ConsoleMixin {
  static LisoAutofillService get to => Get.find();

  // VARIABLES
  final autofill = AutofillService();

  // PROPERTIES
  final supported = false.obs;
  final enabled = false.obs;
  final saving = false.obs;

  @override
  void onInit() async {
    supported.value = await autofill.hasAutofillServicesSupport;
    if (!supported.value) return;

    enabled.value = await autofill.hasEnabledAutofillServices;

    final pref = await autofill.getPreferences();
    saving.value = pref.enableSaving;

    console.info(
      'supported: ${supported.value}, enabled: ${enabled.value}',
    );

    super.onInit();
  }

  void set() async {
    await autofill.requestSetAutofillService();
    enabled.value = await autofill.hasEnabledAutofillServices;

    NotificationsManager.notify(
      title: 'Autofill Service ${enabled.value ? 'Enabled' : 'Disabled'}',
      body: enabled.value
          ? '${ConfigService.to.appName} will now automatically suggest to fill and save forms for you'
          : 'You can enable this setting again anytime',
    );
  }

  void toggleSaving(bool value) async {
    saving.value = value;

    await autofill.setPreferences(AutofillPreferences(
      enableDebug: false,
      enableSaving: value,
    ));
  }
}
