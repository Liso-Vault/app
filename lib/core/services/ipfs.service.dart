import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:get/get.dart';
import 'package:ipfs_rpc/ipfs_rpc.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/extensions.dart';
import 'package:path/path.dart';

import '../hive/models/metadata/metadata.hive.dart';
import '../liso/liso_paths.dart';
import '../utils/globals.dart';
import '../utils/ui_utils.dart';

class IPFSService extends GetxService with ConsoleMixin {
  static IPFSService get to => Get.find();

  // VARIABLES
  final ipfs = IPFS();
  final persistence = Get.find<PersistenceController>();
  bool ready = false;

  // GETTERS
  String get rootPath {
    final address = masterWallet?.address;
    return join('/$kAppName', address);
  }

  String get backupsPath => join(rootPath, 'Backups');
  String get pastPath => join(rootPath, 'Past');

  // FUNCTIONS
  Future<void> init() async {
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
      console.warning(
        'Connected to: ${ipfs.client.baseUrl}',
      );

      // create necessary directories
      console.info('creating directories...');
      await ipfs.files.mkdir(arg: rootPath, parents: true);
      await ipfs.files.mkdir(arg: backupsPath, parents: true);
      await ipfs.files.mkdir(arg: pastPath, parents: true);
    }
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

    // backup a copy to /Past first before modifying/writing
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

    // copy server vault to past before writing
    final serverStat = await _obtainServerStat();
    if (serverStat != null) {
      await _copyToPast(serverStat.hash!);
    }

    // archive to .liso file locally
    final filePath = await _archiveLiso();
    if (filePath.isEmpty) return;

    // write/upload to IPFS
    final fileName = masterWallet!.fileName;
    final result = await ipfs.files.write(
      arg: join(rootPath, fileName),
      fileName: fileName,
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
    persistence.vaultMetadata.val = metadata.toJsonString();
  }

  Future<HiveMetadata?> _obtainLocalMetadata() async {
    HiveMetadata? metadata;

    // create one if doesn't exist
    if (persistence.vaultMetadata.val.isEmpty) {
      metadata = await HiveMetadata.get(); // new
    } else {
      // get updated metadata
      final metadataJson = jsonDecode(persistence.vaultMetadata.val);
      metadata = HiveMetadata.fromJson(metadataJson);
    }

    return metadata;
  }

  Future<void> _syncLocalMetadata() async {
    console.info('syncing local metadata...');

    var metadata = await _obtainLocalMetadata();
    metadata = await metadata!.getUpdated();

    final metadataString = metadata.toJsonString();
    final filePath = join(LisoPaths.temp!.path, kMetadataFileName);
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
        persistence.vaultMetadata.val = metadataString; // save
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
        masterWallet!.fileName,
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

  Future<bool> _copyToPast(String serverHash) async {
    // TODO: Time Machine Limit
    // before copying, check if user has used more than the limit
    // if limit is reached, delete last past item before copying

    console.info('copying vault to /Past...');

    final pastFileName = serverHash + '.$kVaultExtension';

    // backup a copy to /Past first before modifying/writing
    final resultCp = await IPFSService.to.ipfs.files.cp(
      source: join(IPFSService.to.rootPath, masterWallet!.fileName),
      destination: join(IPFSService.to.pastPath, pastFileName),
    );

    bool success = false;

    resultCp.fold(
      (error) {
        if (error.message.contains('already has entry')) {
          return console.info('already have a copy to /Past');
        } else {
          return UIUtils.showSimpleDialog(
            'Error IPFS Sync Preparation',
            error.toJson().toString() + ' > _copyToPast()',
          );
        }
      },
      (response) {
        console.info('successfully copied to /Past');
        success = true;
      },
    );

    return success;
  }

  Future<String> _archiveLiso() async {
    console.info('archiving vault...');

    final encoder = ZipFileEncoder();
    final filePath = join(LisoPaths.temp!.path, masterWallet!.fileName);

    try {
      encoder.create(filePath);
      await encoder.addDirectory(Directory(LisoPaths.hive!.path));
      encoder.close();
    } catch (e) {
      UIUtils.showSimpleDialog(
        'Error IPFS Sync Preparation',
        e.toString() + ' > _archiveLiso()',
      );

      return '';
    }

    return filePath;
  }
}
