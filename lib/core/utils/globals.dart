// COMPANY

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:liso/core/hive/models/metadata/metadata.hive.dart';
import 'package:secrets/secrets.dart';

// HIVE DATABASE
const kHiveBoxGroups = 'groups';
const kHiveBoxCategories = 'categories';
const kHiveBoxItems = 'items';
const kHiveBoxPersistence = 'persistence';
// BIOMETRIC STORAGE
const kBiometricPasswordKey = 'biometric_password';
const kBiometricSeedKey = 'biometric_seed';
// FILE EXTENSIONS
const kVaultExtension = 'liso';
const kWalletExtension = 'json';
const kEncryptedExtensionExtra = '.liso.enc';
// FILE NAMES
const kMetadataFileName = 'metadata.json';
const kVaultFileName = 'vault.$kVaultExtension';
// DESKTOP
const kMinWindowSize = Size(400, 850);
const kDesktopChangePoint = 800.0; // responsive setting
// COLORS
const kAppColor = Color(0xff02f297);
const kAppColorDarker = Color(0xFF00BC74);
// INPUT FORMATTERS
final inputFormatterRestrictSpaces =
    FilteringTextInputFormatter.deny(RegExp(r'\s'));
final inputFormatterNumericOnly =
    FilteringTextInputFormatter.allow(RegExp("[0-9]"));

final isFirebaseSupported = GetPlatform.isMacOS || GetPlatform.isMobile;
final isLocalAuthSupported = GetPlatform.isWindows || GetPlatform.isMobile;
final currencyFormatter = NumberFormat.currency(symbol: '', decimalDigits: 2);

final reservedVaultIds = Secrets.groups.map((e) => e['id'] as String);
final reservedCategories = Secrets.categories.map((e) => e['id'] as String);

const kCipherKeySignatureMessage = 'liso';
const kAuthSignatureMessage = 'auth';
const kS3MetadataVersion = '1';
const kVaultFormatVersion = 1;
const kReleaseMode = ReleaseMode.beta;

bool get isBeta => kReleaseMode == ReleaseMode.beta;

Color get themeColor => Get.isDarkMode ? kAppColor : kAppColorDarker;

// ENUMS
enum ReleaseMode {
  beta,
  production,
}

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
  identity,
  note,
  cashCard,
  bankAccount,
  medicalRecord,
  passport,
  server,
  softwareLicense,
  apiCredential,
  database,
  driversLicense,
  email,
  membership,
  outdoorLicense,
  rewardsProgram,
  socialSecurity,
  wirelessRouter,
  encryption,
  none,
}

enum LisoSyncProvider {
  sia,
  ipfs,
  storj,
  skynet,
  custom,
}

class Globals {
  // VARIABLES
  static bool timeLockEnabled = true;
  static HiveMetadata? metadata;

  // GETTERS

  // FUNCTIONS
  static Future<void> init() async {
    metadata = await HiveMetadata.get();
  }
}
