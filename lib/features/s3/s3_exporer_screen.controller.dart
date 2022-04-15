import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:liso/core/firebase/config/config.service.dart';
import 'package:liso/core/liso/liso.manager.dart';
import 'package:liso/core/utils/console.dart';
import 'package:liso/core/utils/extensions.dart';
import 'package:liso/features/s3/s3.service.dart';
import 'package:path/path.dart';

import '../../core/utils/globals.dart';
import '../../core/utils/ui_utils.dart';
import 'model/s3_content.model.dart';

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

    data.value = await S3Service.to.fetch(
      path: path,
      filterExtensions: ['.$kVaultExtension'],
    );

    currentPath.value = path;
    // set state
    var status = RxStatus.success();
    if (data.isEmpty) status = RxStatus.empty();
    change(false, status: status);
  }

  void backup(S3Content content) async {
    //
  }

  void restore(S3Content content) {
    //
  }

  void test() async {
    final file = await LisoManager.archive();
    if (file == null) return;
    final result = await S3Service.to.upload(file);

    return result.fold(
      (error) => UIUtils.showSimpleDialog(
        'Error Uploading',
        error,
      ),
      (response) => console.info('success: $response'),
    );
  }
}
