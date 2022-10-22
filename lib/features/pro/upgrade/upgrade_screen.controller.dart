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
import '../../../core/utils/utils.dart';
import '../../app/routes.dart';
import '../../supabase/model/gumroad_product.model.dart';
import '../../supabase/supabase_functions.service.dart';

class UpgradeScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static UpgradeScreenController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final busy = false.obs;
  final tabIndex = 0.obs;
  final package = Rx<Package>(Package.fromJson(kPackageInitial));
  final gumroadProduct = const Product().obs;

  // GETTERS
  String get identifier => package.value.identifier;

  StoreProduct get product => package.value.storeProduct;

  bool get isSubscription => product.identifier.contains('.sub.');

  String get priceString =>
      product.introductoryPrice?.priceString ?? product.priceString;

  String get periodUnitName {
    if (product.identifier.contains('annual')) {
      return 'year';
    } else if (product.identifier.contains('month')) {
      return 'month';
    }

    return 'error';
  }

  bool get isFreeTrial => product.introductoryPrice?.price == 0;

  String get promoText {
    final intro = product.introductoryPrice!;

    final percentageDifference_ =
        ((product.price - intro.price) / product.price) * 100;

    return isFreeTrial
        ? '${intro.periodNumberOfUnits} ${GetUtils.capitalizeFirst(intro.periodUnit.name.tr)} ${'free_trial'.tr}'
        : '${percentageDifference_.round()}%\nOFF';
  }

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
    final limits = ConfigService.to.limits;
    var limit_ = limits.free;

    if (tabIndex.value == 0) {
      limit_ = limits.pro;
    } else if (tabIndex.value == 1) {
      limit_ = limits.staker;
    } else if (tabIndex.value == 2) {
      limit_ = limits.holder;
    } else if (tabIndex.value == 3) {
      limit_ = limits.free;
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
    if (!isIAPSupported) return _loadGumroad();
    await ProController.to.load();

    if (ProController.to.packages.isNotEmpty) {
      package.value = ProController.to.packages.first;
    }
  }

  Future<void> _loadGumroad() async {
    change(null, status: RxStatus.loading());
    final result = await SupabaseFunctionsService.to.gumroadProductDetail();
    change(null, status: RxStatus.success());

    result.fold(
      (left) => UIUtils.showSimpleDialog(
        'Gumroad Product Error',
        left,
      ),
      (right) {
        gumroadProduct.value = right.product;
        console.wtf('gumroad product: ${gumroadProduct.value.formattedPrice}');
      },
    );
  }

  void purchase() async {
    if (busy.value) return console.error('still busy');

    if (!isIAPSupported) {
      Utils.openUrl(
        ConfigService.to.general.app.links.store.gumroad,
      );

      Get.back();

      return Utils.adaptiveRouteOpen(
        name: Routes.settings,
        parameters: {'expand': 'other_settings'},
      );
    }

    if (ProController.to.packages.isEmpty) {
      return console.error('empty packages');
    }

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
