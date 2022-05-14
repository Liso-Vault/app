import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/firebase/crashlytics.service.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/services/wallet.service.dart';
import 'package:liso/core/utils/biometric.util.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/drawer/drawer_widget.controller.dart';
import 'package:path/path.dart';

import '../hive/hive.manager.dart';
import 'liso_paths.dart';

class LisoManager {
  // VARIABLES
  static final console = Console(name: 'LisoManager');

  // GETTERS
  static String get mainPath => LisoPaths.main!.path;
  static String get hivePath => LisoPaths.hive!.path;
  static String get tempPath => LisoPaths.temp!.path;

  static String get vaultFilename =>
      '${WalletService.to.address}.$kVaultExtension';
  static String get tempVaultFilePath => join(tempPath, kTempVaultFileName);
  static String get exportVaultFilePath => join(tempPath, vaultFilename);

  // FUNCTIONS
  static Future<Either<dynamic, File>> createArchive(
    Directory directory, {
    required String filePath,
  }) async {
    console.info('archiving...');
    final encoder = ZipFileEncoder();

    try {
      encoder.create(filePath);
      await encoder.addDirectory(directory);
      encoder.close();
    } catch (e, s) {
      CrashlyticsService.to.record(FlutterErrorDetails(
        exception: e,
        stack: s,
      ));

      return Left(e);
    }

    console.info('archived!');
    return Right(File(filePath));
  }

  static Either<dynamic, Archive> readArchive(String path) {
    // console.info('readArchive: $path');

    try {
      final archive = ZipDecoder().decodeBuffer(InputFileStream(path));
      return Right(archive);
    } catch (e, s) {
      CrashlyticsService.to.record(FlutterErrorDetails(
        exception: e,
        stack: s,
      ));

      return Left(e);
    }
  }

  static Future<Either<dynamic, bool>> extractArchive(
    Archive archive, {
    required String path,
    String fileNamePrefix = '',
  }) async {
    // console.info('extractArchive: $path');

    try {
      for (var file in archive.files) {
        if (!file.isFile) continue;
        final outputStream = OutputFileStream(
          join(path, fileNamePrefix + basename(file.name)),
        );

        file.writeContent(outputStream);
        await outputStream.close();
      }

      return const Right(true);
    } catch (e, s) {
      CrashlyticsService.to.record(FlutterErrorDetails(
        exception: e,
        stack: s,
      ));

      return Left(e);
    }
  }

  static Future<Either<dynamic, bool>> extractArchiveFile(
    ArchiveFile file, {
    required String path,
  }) async {
    // console.info('extractArchiveFile: $path');

    final outputStream = OutputFileStream(join(
      LisoManager.tempPath,
      basename(file.name),
    ));

    try {
      file.writeContent(outputStream);
      await outputStream.close();
      return const Right(true);
    } catch (e, s) {
      CrashlyticsService.to.record(FlutterErrorDetails(
        exception: e,
        stack: s,
      ));

      return Left(e);
    }
  }

  static Future<void> reset() async {
    console.info('resetting...');
    // clear filters
    DrawerMenuController.to.clearFilters();
    // delete biometric storage
    await BiometricUtils.delete(kBiometricPasswordKey);
    await BiometricUtils.delete(kBiometricSeedKey);
    // nullify wallet
    Globals.wallet = null;
    // clear wallet persistence
    PersistenceService.to.wallet.val = '';
    // reset hive
    await HiveManager.reset();
    // persistence
    await PersistenceService.to.box.erase();
    // delete FilePicker caches
    if (GetPlatform.isMobile) {
      await FilePicker.platform.clearTemporaryFiles();
    }

    console.info('reset!');
  }
}
