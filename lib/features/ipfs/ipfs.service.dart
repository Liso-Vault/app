import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:get/get.dart';
import 'package:ipfs_rpc/ipfs_rpc.dart';
import 'package:liso/core/services/persistence.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:path/path.dart';

import '../../core/hive/models/metadata/metadata.hive.dart';
import '../../core/liso/liso.manager.dart';
import '../../core/utils/globals.dart';
import '../../core/utils/ui_utils.dart';

class IPFSService extends GetxService with ConsoleMixin {
  static IPFSService get to => Get.find();

  // VARIABLES
  final ipfs = IPFS();
  final persistence = Get.find<PersistenceService>();
  bool ready = false;

  // GETTERS
  String get rootPath {
    return join('/$kAppName', LisoManager.walletAddress);
  }

  String get backupsPath => join(rootPath, 'Backups');
  String get historyPath => join(rootPath, 'History');
  String get filesPath => join(rootPath, 'Files');

  // FUNCTIONS
  Future<bool> init() async {
    console.info('initializing...');

    // initialize IPFS Client config
    ipfs.client.init(
      scheme: persistence.ipfsScheme.val,
      host: persistence.ipfsHost.val,
      port: persistence.ipfsPort.val,
    );

    ready = true;

    final connected = await isConnected();

    if (connected) {
      console.warning('Connected to: ${ipfs.client.baseUrl}');

      if (LisoManager.vaultFilename.isNotEmpty) {
        // create necessary directories
        console.info('creating directories...');
        await ipfs.files.mkdir(arg: rootPath, parents: true);
        await ipfs.files.mkdir(arg: backupsPath, parents: true);
        await ipfs.files.mkdir(arg: historyPath, parents: true);
        await ipfs.files.mkdir(arg: filesPath, parents: true);
      }
    }

    return connected;
  }

  // Check if we are connected to the IPFS Server
  Future<bool> isConnected() async {
    bool connected = false;
    final result = await ipfs.files.ls();

    result.fold(
      (error) => connected = false,
      (response) => connected = true,
    );

    return connected;
  }

  // sync local vault to server
  Future<void> sync() async {
    if (!persistence.ipfsSync.val) {
      return console.error('IPFS Sync is disabled');
    }

    if (!ready) await init();
    console.info('syncing...');
    final localMetadata = await _obtainLocalMetadata();
    HiveMetadata? serverMetadata;

    // backup a copy to /History first before modifying/writing
    try {
      serverMetadata = await _obtainServerMetadata();
    } catch (e) {
      console.error(e.toString());

      return UIUtils.showSimpleDialog(
        'IPFS Connection Failed',
        'Failed to connect to: ${ipfs.client.baseUrl}\nPlease make sure your configuration is correct and your IPFS software is up and running. Exception: ${e.toString()} > sync()',
      );
    }

    // if server metadata is much updated over the local one, cancel operation
    if (serverMetadata != null) {
      if (serverMetadata.updatedTime.isAfter(localMetadata!.updatedTime)) {
        console.info('local is not in sync with server');
        return UIUtils.showSimpleDialog(
          'Local Not In Sync',
          'Local vault is not in sync with server. Please sync the updated vault from server before you can sync your local changes.',
        );
      }

      // cancel sync if already is synced
      if (serverMetadata.updatedTime == localMetadata.updatedTime) {
        return console.warning('local is already in sync with server');
      }
    }

    // copy server vault to history before writing
    final serverStat = await _obtainServerStat();
    if (serverStat != null) {
      await _copyToHistory(serverStat.hash!);
    }

    // archive to .liso file locally
    final filePath = await _archiveLiso();
    if (filePath.isEmpty) return;

    // write/upload to IPFS
    final result = await ipfs.files.write(
      arg: join(rootPath, LisoManager.vaultFilename),
      fileName: LisoManager.vaultFilename,
      filePath: filePath,
      create: true,
      truncate: true,
    );

    // response
    result.fold(
      (error) => UIUtils.showSimpleDialog(
        'Error Syncing To IPFS',
        error.toJson().toString() + ' > sync()',
      ),
      (response) async {
        // sync local metadata
        await _syncLocalMetadata();
        console.warning('synchronization success');
      },
    );
  }

  Future<HiveMetadata?> _obtainServerMetadata() async {
    console.info('obtaining server metadata...');

    HiveMetadata? metadata;

    final result = await ipfs.files.read(
      arg: join(rootPath, kMetadataFileName),
    );

    // response
    result.fold(
      (error) {
        if (error.message.contains('does not exist')) {
          console.info('Server metadata does not exist yet');
        } else {
          console
              .error('Error obtaining metadata from server: ${error.toJson()}');
          throw 'Error obtaining metadata from server: ${error.toJson()}';
        }
      },
      (response) async {
        final metadataJson = jsonDecode(response);
        metadata = HiveMetadata.fromJson(metadataJson);
        console.warning('metadata sync success');
      },
    );

    return metadata;
  }

  Future<void> updateLocalMetadata() async {
    var metadata = await _obtainLocalMetadata();
    metadata = await metadata!.getUpdated();
    persistence.metadata.val = metadata.toJsonString();
  }

  Future<HiveMetadata?> _obtainLocalMetadata() async {
    HiveMetadata? metadata;

    // create one if doesn't exist
    if (persistence.metadata.val.isEmpty) {
      // TODO: check if user first sync, do not overwrite current on ipfs
      metadata = await HiveMetadata.get(); // new
    } else {
      // get updated metadata
      final metadataJson = jsonDecode(persistence.metadata.val);
      metadata = HiveMetadata.fromJson(metadataJson);
    }

    return metadata;
  }

  Future<void> _syncLocalMetadata() async {
    console.info('syncing local metadata...');

    var metadata = await _obtainLocalMetadata();
    metadata = await metadata!.getUpdated();

    final metadataString = metadata.toJsonString();
    final filePath = join(LisoManager.tempPath, kMetadataFileName);
    await File(filePath).writeAsString(metadataString);

    final result = await ipfs.files.write(
      arg: join(rootPath, kMetadataFileName),
      fileName: kMetadataFileName,
      filePath: filePath,
      create: true,
      truncate: true,
    );

    // response
    result.fold(
      (error) => UIUtils.showSimpleDialog(
        'Error Syncing To IPFS',
        error.toJson().toString() + ' > syncMetadata()',
      ),
      (response) async {
        persistence.metadata.val = metadataString; // save
        console.warning('metadata sync success');
      },
    );
  }

  Future<FilesStatResponse?> _obtainServerStat() async {
    console.info('obtaining server stat...');
    FilesStatResponse? stat;

    final resultStat = await IPFSService.to.ipfs.files.stat(
      arg: join(
        IPFSService.to.rootPath,
        LisoManager.vaultFilename,
      ),
    );

    resultStat.fold(
      (error) {
        if (error.message.contains('file does not exist')) {
          // we are a first time user with IPFS Sync
        } else {
          // network error
          throw 'Error: ${error.toJson()}\nPlease try again. > _getServerHash()';
        }
      },
      // we are an existing IPFS Sync User
      (response) => stat = response,
    );

    return stat;
  }

  Future<bool> _copyToHistory(String serverHash) async {
    // TODO: Time Machine Limit
    // before copying, check if user has used more than the limit
    // if limit is reached, delete last history item before copying

    console.info('copying vault to /History...');

    final historyFileName = serverHash + '.$kVaultExtension';

    // backup a copy to /History first before modifying/writing
    final resultCp = await IPFSService.to.ipfs.files.cp(
      source: join(IPFSService.to.rootPath, LisoManager.vaultFilename),
      destination: join(IPFSService.to.historyPath, historyFileName),
    );

    bool success = false;

    resultCp.fold(
      (error) {
        if (error.message.contains('already has entry')) {
          return console.info('already have a copy to /History');
        } else {
          return UIUtils.showSimpleDialog(
            'Error IPFS Sync Preparation',
            error.toJson().toString() + ' > _copyToHistory()',
          );
        }
      },
      (response) {
        console.info('successfully copied to /History');
        success = true;
      },
    );

    return success;
  }

  Future<String> _archiveLiso() async {
    console.info('archiving vault...');
    final encoder = ZipFileEncoder();

    try {
      encoder.create(LisoManager.tempVaultFilePath);
      await encoder.addDirectory(Directory(LisoManager.hivePath));
      encoder.close();
    } catch (e) {
      UIUtils.showSimpleDialog(
        'Error IPFS Sync Preparation',
        e.toString() + ' > _archiveLiso()',
      );

      return '';
    }

    return LisoManager.tempVaultFilePath;
  }
}
