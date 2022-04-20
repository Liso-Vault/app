import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:either_option/either_option.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/biometric.util.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/file.util.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/features/s3/s3.service.dart';
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

  static String get walletAddress =>
      Globals.wallet?.privateKey.address.hexEip55 ?? '';

  static String get walletFileName => 'wallet.$kWalletExtension';

  static String get walletFilePath => join(
        mainPath,
        walletFileName,
      );

  static String get vaultFilename => '$walletAddress.$kVaultExtension';

  static String get tempVaultFilePath => join(tempPath, kTempVaultFileName);

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
    } catch (e) {
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
    } catch (e) {
      console.error('readArchive(): ' + e.toString());
      return Left(e);
    }
  }

  static Future<Either<dynamic, bool>> extractArchive(
    Archive archive, {
    required String path,
  }) async {
    // console.info('extractArchive: $path');

    try {
      for (var file in archive.files) {
        if (!file.isFile) continue;
        final outputStream = OutputFileStream(join(path, basename(file.name)));
        file.writeContent(outputStream);
        await outputStream.close();
      }

      return Right(true);
    } catch (e) {
      console.error('extractArchive(): ' + e.toString());
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
      return Right(true);
    } catch (e) {
      console.error('extractArchive(): ' + e.toString());
      return Left(e);
    }
  }

  static Future<void> reset() async {
    console.info('resetting...');
    // delete biometric storage
    final storage = await BiometricUtils.getStorage();
    await storage.delete();
    // nullify wallet
    Globals.wallet = null;
    // delete files
    await FileUtils.delete(walletFilePath); // wallet
    await FileUtils.delete(tempVaultFilePath); // temp vault
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
