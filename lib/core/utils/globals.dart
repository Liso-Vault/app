import 'package:app_core/config.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/license/license.service.dart';
import 'package:app_core/pages/upgrade/upgrade_config.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/model/config_app_domains.model.dart';
import 'package:liso/core/firebase/model/config_limits.model.dart';
import 'package:secrets/secrets.dart';

import '../../features/config/pricing.dart';
import '../../features/wallet/wallet.service.dart';
import '../persistence/persistence.dart';

bool isAutofill = false;

var configLimits = ConfigLimits.fromJson(Secrets.limits);
var configAppDomains = ConfigAppDomains.fromJson(Secrets.appDomains);

// HIVE DATABASE
const kHiveBoxGroups = 'groups';
const kHiveBoxCategories = 'categories';
const kHiveBoxItems = 'items';
const kHiveBoxSecretPersistence = 'secret_persistence';
// BIOMETRIC STORAGE
const kBiometricPasswordKey = 'biometric_password';
const kBiometricSeedKey = 'biometric_seed';
// FILE EXTENSIONS
const kVaultExtension = 'liso';
const kWalletExtension = 'json';
const kEncryptedExtensionExtra = '.$kVaultExtension.enc';
// FILE NAMES
const kMetadataFileName = 'metadata.json';
const kVaultFileName = 'vault.$kVaultExtension';

// INPUT FORMATTERS
final inputFormatterRestrictSpaces =
    FilteringTextInputFormatter.deny(RegExp(r'\s'));
final inputFormatterNumericOnly =
    FilteringTextInputFormatter.allow(RegExp("[0-9]"));

const kCipherKeySignatureMessage = 'liso';
const kAuthSignatureMessage = 'auth';
const kVaultFormatVersion = 1;

const kNonPasswordFieldIds = [
  'key',
  'private_key',
  'secret',
  'pin',
  'verification_number',
  'seed',
];

const kGiveawayImageUrl =
    'https://media2.giphy.com/media/QlvPwCTw59B2E/giphy.gif?cid=ecf05e47twvo15bd95yww38qnr0b24bxvs83rqtss333b90s&rid=giphy.gif&ct=g';

// GETTERS

const kAppColor = Color(0xff02f297);
const kAppColorDarker = Color(0xFF00A465);

Color get themeColor => Get.isDarkMode ? kAppColor : kAppColorDarker;

Color get proColor => Get.isDarkMode ? kAppColor : kAppColorDarker;

bool get isCryptoSupported => !isApple;

ConfigLimitsTier get limits {
  if (!WalletService.to.isReady) return configLimits.free;
  // check if user is a pro subscriber
  if (LicenseService.to.isPremium) return configLimits.pro;

  // TODO: check if user is a staker

  // check if user is a holder
  if (AppPersistence.to.lastLisoBalance.val >
      configLimits.holder.tokenThreshold) {
    return configLimits.holder;
  }

  // free user
  return configLimits.free;
}

// FUNCTIONS

void initUpgradeConfig() {
  final upgradeConfig = UpgradeConfig(
    pricing: AppPricing.data,
  );

  CoreConfig().upgradeConfig = upgradeConfig;
}

// ENUMS

enum LisoItemSortOrder {
  titleAscending,
  titleDescending,
  categoryAscending,
  categoryDescending,
  dateModifiedAscending,
  dateModifiedDescending,
  dateCreatedAscending,
  dateCreatedDescending,
  favoriteAscending,
  favoriteDescending,
  protectedAscending,
  protectedDescending,
}

enum LisoItemCategory {
  cryptoWallet,
  login,
  password,
  email,
  otp,
  note,
  insurance,
  healthInsurance,
  cashCard,
  bankAccount,
  identity,
  passport,
  medicalRecord,
  driversLicense,
  wirelessRouter,
  softwareLicense,
  membership,
  outdoorLicense,
  rewardsProgram,
  socialSecurity,
  apiCredential,
  database,
  server,
  encryption,
  custom,
}

enum LisoSyncProvider { sia, custom }
