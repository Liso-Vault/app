import 'package:console_mixin/console_mixin.dart';
// import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:get/get.dart';

import '../../../core/hive/models/field.hive.dart';
import '../../../core/hive/models/item.hive.dart';

class AutofillPickerDialogController extends GetxController with ConsoleMixin {
  // VARIABLES
  late HiveLisoItem item;
  late String username;
  late String password;

  // PROPERTIES
  final data = <HiveLisoField>[].obs;
  final mode = AutofillPickerMode.username.obs;

  void load() {
    if (mode.value == AutofillPickerMode.username) {
      final usernameFields = item.usernameFields;

      if (usernameFields.length == 1) {
        username = usernameFields.first.data.value!;
        mode.value = AutofillPickerMode.password;
        return load();
      }

      data.value = usernameFields.toList();
    } else if (mode.value == AutofillPickerMode.password) {
      final passwordFields = item.passwordFields;

      if (passwordFields.length == 1) {
        password = passwordFields.first.data.value!;

        // return Get.back(result: [
        //   PwDataset(
        //     label: item.title,
        //     username: username,
        //     password: password,
        //   )
        // ]);
      }

      data.value = passwordFields.toList();
    }
  }
}

enum AutofillPickerMode {
  username,
  password,
}
