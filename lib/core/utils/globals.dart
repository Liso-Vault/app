import 'package:app_core/config.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/pages/upgrade/upgrade_config.dart';
import 'package:app_core/purchases/purchases.services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:liso/features/config/limits.model.dart';

import '../../features/config/license.model.dart';
import '../../features/config/pricing.dart';
import '../../features/wallet/wallet.service.dart';
import '../persistence/persistence.dart';

bool isAutofill = false;

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

const kOliverTwitterUrl = 'https://twitter.com/oliverbytes';
const kGiveawayImageUrl = 'https://i.imgur.com/P37ko6F.gif';

String generatedSeed = '';

// GETTERS

const kAppColor = Color(0xff02f297);
const kAppColorDarker = Color(0xFF00A465);

Color get themeColor => Get.isDarkMode ? kAppColor : kAppColorDarker;

Color get proColor => Get.isDarkMode ? kAppColor : kAppColorDarker;

bool get isCryptoSupported => !isApple || kDebugMode;

ExtraLimitsConfigTier get limits {
  if (!WalletService.to.isReady) return licenseConfig.free;
  // check if user is a pro subscriber
  if (PurchasesService.to.isPremium) return licenseConfig.pro;

  // TODO: check if user is a staker

  // check if user is a holder
  if (AppPersistence.to.lastLisoBalance.val >
      licenseConfig.holder.tokenThreshold) {
    return licenseConfig.holder;
  }

  // free user
  return licenseConfig.free;
}

// FUNCTIONS

void initUpgradeConfig() {
  final upgradeConfig = UpgradeConfig(
    pricing: AppPricing.data,
    featureTileFontSize: 14,
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
