import 'dart:async';
import 'dart:convert';

import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:liso/core/firebase/auth.service.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:liso/features/wallet/wallet.service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/firebase/config/config.service.dart';
import '../../core/firebase/config/models/config_limits.model.dart';
import '../../core/middlewares/authentication.middleware.dart';
import '../../core/persistence/persistence.dart';
import '../../core/utils/globals.dart';
import '../connectivity/connectivity.service.dart';

class ProController extends GetxController with ConsoleMixin {
  static ProController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final info = Rx<PurchaserInfo>(PurchaserInfo.fromJson(kPurchaserInfoInitial));
  final offerings = Rx<Offerings>(Offerings.fromJson(kOfferingsInitial));

  // GETTERS

  bool get isPro => proEntitlement?.isActive ?? false;
  // bool get isPro => false;

  bool get isFreeTrial => !AuthService.to.isSignedIn
      ? false
      : AuthService.to.user!.metadata.creationTime!.isBefore(
          DateTime.tryParse(Persistence.to.lastServerDateTime.val) ??
              DateTime.now());

  DateTime get freeTrialExpirationDateTime =>
      (AuthService.to.user?.metadata.creationTime ?? DateTime.now()).add(
        Duration(
          days: ConfigService.to.limits.settings.trialDays,
        ),
      );

  String get freeTrialExpirationDateTimeString =>
      DateFormat.yMMMMd().add_jm().format(freeTrialExpirationDateTime);

  EntitlementInfo? get proEntitlement => info.value.entitlements.all['pro'];

  List<Package> get packages =>
      offerings.value.current?.availablePackages ?? [];

  String get proPrefixString =>
      proEntitlement!.willRenew ? 'renews'.tr : 'expires'.tr;

  String get proDateString => DateFormat.yMMMMd()
      .add_jm()
      .format(DateTime.parse(proEntitlement!.expirationDate!).toLocal());

  ConfigLimitsTier get limits {
    final limits_ = ConfigService.to.limits;

    if (!WalletService.to.isReady) return limits_.free;

    // check if user is a pro subscriber
    if (isPro) return limits_.pro;
    // check if user is whitelisted by developer
    final users = ConfigService.to.users.users.where(
      (e) => e.address == WalletService.to.longAddress,
    );

    if (users.isNotEmpty) {
      final user = users.first;

      if (user.limits == 'holder') {
        return limits_.holder;
      } else if (user.limits == 'staker') {
        return limits_.staker;
      } else if (user.limits == 'pro') {
        return limits_.pro;
      } else if (user.limits == 'trial') {
        return limits_.trial;
      }
    }

    // TODO: check if user is a staker
    // check if user is a holder
    if (Persistence.to.lastLisoBalance.val > limits_.holder.tokenThreshold) {
      return limits_.holder;
    }

    // check if user is still in trial mode
    if (isFreeTrial) return limits_.trial;

    // free user
    return limits_.free;
  }

  // INIT

  @override
  void onClose() {
    if (!ready) return;
    Purchases.removePurchaserInfoUpdateListener((info_) {
      info.value = info_;
    });

    super.onClose();
  }

  // FUNCTIONS
  bool get ready {
    if (!ConnectivityService.to.connected.value) {
      if (AuthenticationMiddleware.initialized) {
        UIUtils.showSimpleDialog(
          'Network Error',
          'No internet connection',
        );
      }

      return false;
    }

    return GetPlatform.isWindows != true;
  }

  Future<void> init() async {
    if (!ready) return;
    await Purchases.setDebugLogsEnabled(true);

    await Purchases.setup(
      ConfigService.to.secrets.revenuecat.apiKey,
      appUserId: AuthService.to.user?.uid,
    );

    Purchases.addPurchaserInfoUpdateListener((info_) {
      info.value = info_;
    });

    sync();
  }

  Future<void> login() async {
    if (!ready) return;
    await Purchases.logIn(AuthService.to.userId);

    await Purchases.setAttributes({
      'wallet-address': Persistence.to.walletAddress.val,
    });
  }

  Future<void> logout() async {
    if (!ready) return;
    // prevent exception if logging out with an anonymous user
    if (await Purchases.isAnonymous) {
      return console.error('anonymous user');
    }

    try {
      await Purchases.logOut();
    } on PlatformException catch (e) {
      console.error('exception error: $e');
    } catch (e) {
      console.error('logout error: $e');
    }
  }

  Future<void> load() async {
    if (!ready) return;

    try {
      offerings.value = await Purchases.getOfferings();
    } on PlatformException catch (e) {
      console.error('load error: $e');
      _showError(e);
    }
  }

  Future<void> sync() async {
    if (!ready) return;

    try {
      info.value = await Purchases.getPurchaserInfo();
      // console.warning('sync: ${jsonEncode(info.value.toJson())}');
    } on PlatformException catch (e) {
      return console.error('sync error: $e');
    }
  }

  Future<void> purchase(Package package) async {
    if (!ready) return;
    Globals.timeLockEnabled = false; // temporarily disable
    PurchaserInfo? info_;

    try {
      info_ = await Purchases.purchasePackage(package);
      console.warning('purchase: ${jsonEncode(info_.toJson())}');
    } on PlatformException catch (e) {
      console.error('purchase error: $e');
      Globals.timeLockEnabled = true;
      _showError(e);
      return;
    }

    info.value = info_;
    Globals.timeLockEnabled = true;
  }

  Future<void> restore() async {
    if (!ready) return;
    PurchaserInfo? info_;

    try {
      info_ = await Purchases.restoreTransactions();
      console.warning('restore: ${jsonEncode(info_.toJson())}');
    } on PlatformException catch (e) {
      _showError(e);
      return;
    }

    info.value = info_;
  }

  Future<void> _showError(PlatformException e) async {
    final errorCode = PurchasesErrorHelper.getErrorCode(e);
    console.error('errorCode: ${errorCode.name}');

    String errorMessage =
        'Code: ${errorCode.name}. Please report to the developer.';

    switch (errorCode) {
      case PurchasesErrorCode.purchaseCancelledError:
        errorMessage = '';
        break;
      case PurchasesErrorCode.purchaseNotAllowedError:
        errorMessage =
            'For some reason you or the device is not allowed to do purchases';
        break;
      case PurchasesErrorCode.purchaseInvalidError:
        errorMessage = 'Invalid purchase';
        break;
      case PurchasesErrorCode.productAlreadyPurchasedError:
        break;
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        errorMessage =
            'The package you selected is currently not available for purchase';
        break;
      case PurchasesErrorCode.configurationError:
        break;
      case PurchasesErrorCode.ineligibleError:
        errorMessage = 'Ineligible to purchase this package';
        break;
      case PurchasesErrorCode.insufficientPermissionsError:
        break;
      case PurchasesErrorCode.invalidAppUserIdError:
        break;
      case PurchasesErrorCode.invalidAppleSubscriptionKeyError:
        break;
      case PurchasesErrorCode.invalidCredentialsError:
        break;
      case PurchasesErrorCode.invalidReceiptError:
        break;
      case PurchasesErrorCode.invalidSubscriberAttributesError:
        break;
      case PurchasesErrorCode.missingReceiptFileError:
        break;
      case PurchasesErrorCode.networkError:
        errorMessage = 'A network error occurred. Please try again.';
        break;
      case PurchasesErrorCode.operationAlreadyInProgressError:
        errorMessage = 'The operation is already in progress';
        break;
      case PurchasesErrorCode.paymentPendingError:
        errorMessage = 'The payment is already pending';
        break;
      case PurchasesErrorCode.receiptAlreadyInUseError:
        break;
      case PurchasesErrorCode.receiptInUseByOtherSubscriberError:
        break;
      case PurchasesErrorCode.storeProblemError:
        errorMessage =
            'There was a problem with ${GetPlatform.isIOS ? 'the App Store' : 'Google Play'}';
        break;
      case PurchasesErrorCode.unexpectedBackendResponseError:
        break;
      case PurchasesErrorCode.unknownBackendError:
        break;
      case PurchasesErrorCode.unsupportedError:
        break;
      case PurchasesErrorCode.unknownError:
        errorMessage = 'Unknown error. Please report to the developer.';
        break;
      default:
        errorMessage = 'Weird error. Please report to the developer.';
        break;
    }

    if (errorMessage.isEmpty) return;

    await UIUtils.showSimpleDialog(
      'Purchase Error',
      errorMessage,
    );
  }
}

const kPurchaserInfoInitial = {
  "entitlements": {"all": {}, "active": {}},
  "allPurchaseDates": {},
  "activeSubscriptions": [],
  "allPurchasedProductIdentifiers": [],
  "nonSubscriptionTransactions": [],
  "firstSeen": "",
  "originalAppUserId": "",
  "allExpirationDates": {},
  "requestDate": "",
  "latestExpirationDate": null,
  "originalPurchaseDate": null,
  "originalApplicationVersion": null,
  "managementURL": null
};

const kOfferingsInitial = {
  "all": {
    "default": {
      "identifier": "",
      "serverDescription": "",
      "availablePackages": [],
      "lifetime": null,
      "annual": null,
      "sixMonth": null,
      "threeMonth": null,
      "twoMonth": null,
      "monthly": null,
      "weekly": null,
    }
  },
  "current": {
    "identifier": "",
    "serverDescription": "",
    "availablePackages": [],
    "lifetime": null,
    "annual": null,
    "sixMonth": null,
    "threeMonth": null,
    "twoMonth": null,
    "monthly": null,
  }
};

const kPackageInitial = {
  "identifier": "",
  "packageType": "",
  "product": {
    "identifier": "",
    "description": "",
    "title": "",
    "price": 0.0,
    "price_string": "",
    "currency_code": "",
    "introPrice": {
      "price": 0.0,
      "priceString": "",
      "period": "",
      "cycles": 0,
      "periodUnit": "",
      "periodNumberOfUnits": 0
    },
    "discounts": []
  },
  "offeringIdentifier": "annual",
};
