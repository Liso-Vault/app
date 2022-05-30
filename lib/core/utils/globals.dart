// COMPANY

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// HIVE DATABASE
const kHiveBoxItems = 'items';
const kHiveBoxPersistence = 'persistence';
// const kHiveBoxSharedVaultCredentials = 'shared_vaults';
const kHiveBoxGroups = 'groups';
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

const kReservedVaultIds = 'personal,work,family,others,secrets';

final currencyFormatter = NumberFormat.currency(symbol: '', decimalDigits: 2);

const kCipherKeySignatureMessage = 'liso';
const kAuthSignatureMessage = 'auth';
const kS3MetadataVersion = '1';
const kVaultFormatVersion = 1;

Color get themeColor => Get.isDarkMode ? kAppColor : kAppColorDarker;

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

  // GETTERS

  // FUNCTIONS
}
