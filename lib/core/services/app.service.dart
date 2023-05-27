import 'dart:async';

import 'package:app_core/services/main.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';

import '../../features/supabase/model/status.model.dart';
import 'global.service.dart';

class AppService extends GetxService with ConsoleMixin {
  static AppService get to => Get.find();

  // VARIABLES

  // GETTERS

  // INIT

  Future<void> reset() async {
    console.info('resetting...');
    GlobalService.to.userStatus.value = const Status();
    await MainService.to.reset();
    console.info('reset!');
  }
}
