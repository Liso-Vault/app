import 'package:get/get.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:path/path.dart';

import '../../../core/utils/globals.dart';
import '../../../core/utils/ui_utils.dart';
import '../model/s3_content.model.dart';

class S3ExplorerScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => S3ExplorerScreenController());
  }
}

class S3ExplorerScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static S3ExplorerScreenController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final data = <S3Content>[].obs;
  final currentPath = ''.obs;
  final busy = false.obs;

  // PROPERTIES

  // GETTERS
  bool get canUp => currentPath.value != S3Service.to.rootPath;

  // INIT
  @override
  void onInit() {
    load(path: S3Service.to.rootPath);
    super.onInit();
  }

  @override
  void change(newState, {RxStatus? status}) {
    if (newState != null) busy.value = newState;
    super.change(newState, status: status);
  }

  // FUNCTIONS
  void reload() => load(path: currentPath.value);

  void up() => load(path: dirname(currentPath.value) + '/');

  void load({required String path}) async {
    change(true, status: RxStatus.loading());

    final result = await S3Service.to.fetch(
      path: path,
      filterExtensions: ['.$kVaultExtension'],
    );

    result.fold(
      (error) {
        UIUtils.showSimpleDialog(
          'Fetch Error',
          '$error -> load()',
        );

        change(false, status: RxStatus.success());
      },
      (response) {
        data.value = response;
        currentPath.value = path;

        change(
          false,
          status: data.isEmpty ? RxStatus.empty() : RxStatus.success(),
        );
      },
    );
  }

  void backup(S3Content content) async {
    final result = await S3Service.to.backup(content);

    result.fold(
      (error) => UIUtils.showSimpleDialog(
        'Error Backup',
        error,
      ),
      (response) => console.info('success: $response'),
    );
  }

  void restore(S3Content content) {
    //
  }

  void upload() {
    //
  }

  void test() async {
    S3Service.to.upSync();
  }
}

// TODO: explorer type
enum S3ExplorerType {
  picker,
  timeMachine,
}
