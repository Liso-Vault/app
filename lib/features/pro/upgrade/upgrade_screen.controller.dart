import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/notifications/notifications.manager.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/pro/pro.controller.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/firebase/config/models/config_limits.model.dart';

class UpgradeScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static UpgradeScreenController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final busy = false.obs;
  final tabIndex = 0.obs;
  final package = Rx<Package>(Package.fromJson(kPackageInitial));

  // GETTERS
  String get identifier => package.value.identifier;

  bool get isSubscription => package.value.product.identifier.contains('.sub.');

  String get priceString =>
      package.value.product.introductoryPrice?.priceString ??
      package.value.product.priceString;

  int get limitIndex {
    int index = 3;

    switch (ProController.to.limits.id) {
      case 'pro':
        index = 0;
        break;
      case 'staker':
        index = 1;
        break;
      case 'holder':
        index = 2;
        break;
      case 'free':
        index = 3;
        break;
      case 'trial':
        index = 4;
        break;
    }

    return index;
  }

  List<Tab> get tabBarItems => [
        const Tab(text: 'Pro'),
        if (limitIndex >= 1) ...[
          const Tab(text: 'Staker'),
          if (limitIndex >= 2) ...[
            const Tab(text: 'Holder'),
            if (limitIndex >= 3) ...[
              const Tab(text: 'Free'),
            ]
          ]
        ],
      ];

  ConfigLimitsTier get selectedLimit {
    var limit_ = ConfigService.to.limits.free;

    if (tabIndex.value == 0) {
      limit_ = ConfigService.to.limits.pro;
    } else if (tabIndex.value == 1) {
      limit_ = ConfigService.to.limits.staker;
    } else if (tabIndex.value == 2) {
      limit_ = ConfigService.to.limits.holder;
    } else if (tabIndex.value == 3) {
      limit_ = ConfigService.to.limits.free;
    }

    return limit_;
  }

  // INIT
  @override
  void onInit() async {
    _load();
    change(null, status: RxStatus.success());
    super.onInit();
  }

  @override
  void onReady() {
    final title = Get.parameters['title'];
    final body = Get.parameters['body'];

    if (title != null && body != null) {
      UIUtils.showImageDialog(
        Icon(LineIcons.rocket, size: 100, color: proColor),
        title: title,
        body: body,
      );
    }

    super.onReady();
  }

  @override
  void change(newState, {RxStatus? status}) {
    busy.value = status?.isLoading ?? false;
    super.change(newState, status: status);
  }

  // FUNCTIONS
  Future<void> _load() async {
    await ProController.to.load();

    if (ProController.to.packages.isNotEmpty) {
      package.value = ProController.to.packages.first;
    }
  }

  void purchase() async {
    if (busy.value) return console.error('still busy');
    change(null, status: RxStatus.loading());

    final package = ProController.to.packages.firstWhere(
      (e) => e.identifier == identifier,
    );

    await ProController.to.purchase(package);
    change(null, status: RxStatus.success());

    if (ProController.to.isPro) {
      NotificationsManager.notify(
        title: '${ConfigService.to.appName} Pro Activated',
        body: 'Thank you for upgrading',
      );

      Get.back();
    }
  }

  void restore() async {
    if (busy.value) return console.error('still busy');
    change(null, status: RxStatus.loading());
    await ProController.to.restore();
    change(null, status: RxStatus.success());

    if (ProController.to.isPro) {
      NotificationsManager.notify(
        title: '${ConfigService.to.appName} Pro Restored',
        body: 'Thanks for being a ${ConfigService.to.appName} Pro rockstar!',
      );

      Get.back();
    } else {
      UIUtils.showSimpleDialog(
        'No Purchases',
        'You are not subscribed to ${ConfigService.to.appName} Pro',
      );
    }
  }
}

enum Tier {
  zero,
  one,
  two,
  three,
}
