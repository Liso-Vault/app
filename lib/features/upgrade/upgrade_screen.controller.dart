import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/config/config.service.dart';

import '../../core/firebase/config/models/config_limits.model.dart';

class UpgradeScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UpgradeScreenController(), fenix: true);
  }
}

class UpgradeScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static UpgradeScreenController get to => Get.find();

  // VARIABLES
  final tabIndex = 0.obs;

  // PROPERTIES
  final busy = false.obs;

  ConfigLimitsSetting get tierSetting {
    var tier_ = ConfigService.to.limits.tier0;

    switch (tabIndex.value) {
      case 0:
        tier_ = ConfigService.to.limits.tier0;
        break;
      case 1:
        tier_ = ConfigService.to.limits.tier1;
        break;
      case 2:
        tier_ = ConfigService.to.limits.tier2;
        break;
      case 3:
        tier_ = ConfigService.to.limits.tier3;
        break;
      default:
    }

    return tier_;
  }

  // PROPERTIES
  final data = <Widget>[].obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    change(null, status: RxStatus.success());
    super.onInit();
  }

  @override
  void change(newState, {RxStatus? status}) {
    busy.value = status?.isLoading ?? false;
    super.change(newState, status: status);
  }

  // FUNCTIONS
}

enum Tier {
  zero,
  one,
  two,
  three,
}
