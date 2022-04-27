// COMPANY

import 'dart:typed_data';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/credentials.dart';

// HIVE DATABASE
const kHiveBoxItems = 'items';
// BIOMETRIC STORAGE
const kBiometricPasswordKey = 'biometric_password';
const kBiometricSeedKey = 'biometric_seed';
// FILE EXTENSIONS
const kVaultExtension = 'liso';
const kWalletExtension = 'json';
// FILE NAMES
const kMetadataFileName = 'metadata.json';
const kTempVaultFileName = 'temp_vault.liso';
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

// INPUT DECORATIONS
const kSecondaryInputDecoration = InputDecoration(
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(
      style: BorderStyle.solid,
      color: Color.fromARGB(255, 85, 85, 85),
    ),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(
      style: BorderStyle.solid,
      color: kAppColor,
    ),
  ),
  errorBorder: UnderlineInputBorder(
    borderSide: BorderSide(
      style: BorderStyle.solid,
      color: Color.fromARGB(255, 85, 85, 85),
    ),
  ),
  focusedErrorBorder: UnderlineInputBorder(
    borderSide: BorderSide(
      style: BorderStyle.solid,
      color: FlexColor.materialDarkError,
    ),
  ),
);

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

class Globals {
  // VARIABLES
  static bool timeLockEnabled = true;
  static Wallet? wallet;

  // GETTERS
  static Uint8List get encryptionKey => wallet!.privateKey.privateKey;
}
