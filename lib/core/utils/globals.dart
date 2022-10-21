// COMPANY

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:liso/core/hive/models/metadata/metadata.hive.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/utils/utils.dart';
import 'package:uuid/uuid.dart';

// HIVE DATABASE
const kHiveBoxGroups = 'groups';
const kHiveBoxCategories = 'categories';
const kHiveBoxItems = 'items';
const kHiveBoxPersistence = 'persistence';
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
// DESKTOP
const kMinWindowSize = Size(400, 400);
const kDesktopChangePoint = 800.0; // responsive setting
// COLORS
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

const kNonPasswordFieldIds = [
  'key',
  'private_key',
  'secret',
  'pin',
  'verification_number',
  'seed',
];

// GETTERS

bool get isReviewable => isApple || GetPlatform.isAndroid;
bool get isApple => GetPlatform.isMacOS || GetPlatform.isIOS;
bool get isLinux => GetPlatform.isLinux && !GetPlatform.isWeb;
bool get isWindows => GetPlatform.isWindows && !GetPlatform.isWeb;
bool get isMac => GetPlatform.isMacOS && !GetPlatform.isWeb;

bool get isWindowsLinux =>
    !GetPlatform.isWeb && (GetPlatform.isWindows || GetPlatform.isLinux);

bool get isDesktop =>
    !GetPlatform.isWeb &&
    (GetPlatform.isMacOS || GetPlatform.isWindows || GetPlatform.isLinux);

bool get isPurchasesSupported => GetPlatform.isMacOS || GetPlatform.isMobile;

bool get isLocalAuthSupported =>
    GetPlatform.isMobile && Persistence.to.biometrics.val;

bool get isRateReviewSupported =>
    !GetPlatform.isWeb && GetPlatform.isAndroid ||
    GetPlatform.isIOS ||
    (GetPlatform.isMacOS && isMacAppStore);

bool get isIAPSupported =>
    !GetPlatform.isWeb && (GetPlatform.isMacOS || GetPlatform.isMobile);

bool get isGumroadSupported => !isIAPSupported;

const kAppColor = Color(0xff02f297);
const kAppColorDarker = Color(0xFF00A465);

Color get themeColor => Get.isDarkMode ? kAppColor : kAppColorDarker;

Color get proColor => Get.isDarkMode ? kAppColor : kAppColorDarker;

double get popupItemHeight =>
    Utils.isSmallScreen ? kMinInteractiveDimension : 30;

double? get popupIconSize => Utils.isSmallScreen ? null : 20;

// TODO: set before releasing a new version
const releaseMode = ReleaseMode.production;
bool get isBeta => releaseMode == ReleaseMode.beta;
// firebase emulator settings
const kUseFirebaseEmulator = false;
const kFirebaseHost = 'localhost';
const kFirebaseAuthPort = 9099;
const kFirebaseFunctionsPort = 5001;
const kFirebaseFirestorePort = 8085;

// TODO: set to false when publishing on Mac App Store
const isMacAppStore = true;
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

enum LisoSyncProvider {
  sia,
  // ipfs,
  // storj,
  // skynet,
  custom,
}

class Globals {
  // VARIABLES
  static bool timeLockEnabled = true;
  static bool isAutofill = false;
  static String sessionId = const Uuid().v4();
  static HiveMetadata? metadata;

  // GETTERS

  // FUNCTIONS
  static Future<void> init() async {
    metadata = await HiveMetadata.get();
  }
}
