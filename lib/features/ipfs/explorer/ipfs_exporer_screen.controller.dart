import 'package:get/get.dart';
import 'package:ipfs_rpc/ipfs_rpc.dart';
import 'package:liso/core/services/ipfs.service.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/globals.dart';
import 'package:liso/core/utils/ui_utils.dart';
import 'package:path/path.dart';

class IPFSExplorerScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => IPFSExplorerScreenController());
  }
}

class IPFSExplorerScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static IPFSExplorerScreenController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final data = <FilesLsEntry>[].obs;
  final currentPath = '/$kAppName'.obs;

  // PROPERTIES

  // GETTERS
  bool get canUp => currentPath.value != '/$kAppName';

  // INIT

  @override
  void onInit() {
    load();
    super.onInit();
  }

  // FUNCTIONS

  void load({String path = '/$kAppName'}) async {
    change(null, status: RxStatus.loading());

    final result = await IPFSService.to.ipfs.files.ls(
      arg: path,
      long: true,
    );

    result.fold(
      (error) {
        change(null, status: RxStatus.error());
      },
      (response) {
        // filter .liso files only
        data.value = response.entries
            .where(
              (e) =>
                  e.type == FilesLsEntryType.directory ||
                  extension(e.name) == '.$kVaultExtension',
            )
            .toList();

        currentPath.value = path;
        RxStatus status = RxStatus.success();
        if (data.isEmpty) status = RxStatus.empty();
        change(null, status: status);
      },
    );
  }

  void up() => load(path: dirname(currentPath.value));

  void backup(FilesLsEntry entry) async {
    change(null, status: RxStatus.loading());
    final fileName = entry.hash + '.$kVaultExtension';

    final result = await IPFSService.to.ipfs.files.cp(
      source: join(currentPath.value, entry.name),
      destination: join(IPFSService.to.backupsPath, fileName),
    );

    result.fold(
      (error) {
        change(null, status: RxStatus.success());

        if (error.message.contains('already has entry')) {
          return UIUtils.showSimpleDialog(
            'Already Backed Up',
            'You already have a backup of this vault with hash: ${entry.hash}',
          );
        }

        return UIUtils.showSimpleDialog(
          'Error Backing Up',
          'Failed to copy ${entry.hash} to ${IPFSService.to.backupsPath} with error: ${error.toJson()}',
        );
      },
      (response) {
        change(null, status: RxStatus.success());

        UIUtils.showSnackBar(
          title: 'Success',
          message: 'Successfully backed up ${entry.hash}',
        );
      },
    );
  }

  void restore(FilesLsEntry entry) {
    //
  }
}
