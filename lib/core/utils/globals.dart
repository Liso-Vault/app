// COMPANY

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:liso/core/hive/models/metadata/metadata.hive.dart';
import 'package:liso/core/persistence/persistence.dart';

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

final currencyFormatter = NumberFormat.currency(symbol: '', decimalDigits: 2);
final kFormatter = NumberFormat.compact();

const kCipherKeySignatureMessage = 'liso';
const kAuthSignatureMessage = 'auth';
const kS3MetadataVersion = '1';
const kVaultFormatVersion = 1;
const kNonPasswordFieldIds = ['key', 'private_key', 'secret'];

// GETTERS

bool get isPurchasesSupported => !GetPlatform.isWindows;

bool get isLocalAuthSupported =>
    GetPlatform.isMobile && Persistence.to.biometrics.val;

Color get themeColor => Get.isDarkMode ? kAppColor : kAppColorDarker;

Color get proColor => Get.isDarkMode ? Colors.cyanAccent : Colors.cyan;

// TODO: set before releasing a new version
const kReleaseMode = ReleaseMode.production;
bool get isBeta => kReleaseMode == ReleaseMode.beta;

// TODO: set to false when publishing on Mac App Store
const isMacAppStore = false;
bool get isCryptoSupported =>
    Persistence.to.proTester.val ||
    (GetPlatform.isMacOS && !isMacAppStore) ||
    GetPlatform.isAndroid ||
    GetPlatform.isWindows;

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
  email,
  otp,
  note,
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
