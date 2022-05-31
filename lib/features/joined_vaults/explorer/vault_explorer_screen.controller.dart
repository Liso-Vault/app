import 'dart:convert';
import 'dart:typed_data';

import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:liso/core/hive/hive_items.service.dart';

import '../../../core/hive/models/item.hive.dart';
import '../../../core/liso/liso_paths.dart';
import '../../../core/services/cipher.service.dart';
import '../../../core/utils/globals.dart';
import '../../../core/utils/ui_utils.dart';
import '../../s3/s3.service.dart';
import '../../shared_vaults/model/shared_vault.model.dart';

class VaultExplorerScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VaultExplorerScreenController(), fenix: true);
  }
}

class VaultExplorerScreenController extends GetxController
    with ConsoleMixin, StateMixin {
  static VaultExplorerScreenController get to => Get.find();
  static late SharedVault vault;

  // VARIABLES

  // PROPERTIES
  final data = <HiveLisoItem>[].obs;
  final busy = false.obs;

  // PROPERTIES

  // GETTERS

  // INIT
  @override
  void onInit() {
    init();
    super.onInit();
  }

  @override
  void change(newState, {RxStatus? status}) {
    busy.value = status?.isLoading ?? false;
    super.change(newState, status: status);
  }

  // FUNCTIONS
  void init() async {
    // download vault file
    final s3Path = '${vault.address}/Shared/${vault.docId}.$kVaultExtension';

    final result = await S3Service.to.downloadFile(
      s3Path: s3Path,
      filePath: LisoPaths.tempVaultFilePath,
    );

    if (result.isLeft) {
      final message =
          'The shared vault file with ID: ${vault.docId} cannot be found';
      change(null, status: RxStatus.error(message));

      return UIUtils.showSimpleDialog(
        'Shared Vault File Not Found',
        message,
      );
    }

    // obtain cipher key
    final items_ = HiveItemsService.to.data
        .where((e) => e.identifier == vault.docId)
        .toList();

    if (items_.isEmpty) {
      const message = 'Missing cipher key from vault';
      change(null, status: RxStatus.error(message));

      return UIUtils.showSimpleDialog(
        'Cipher Key Not Found',
        message,
      );
    }

    final fields_ =
        items_.first.fields.where((e) => e.identifier == 'key').toList();

    if (fields_.isEmpty) {
      const message = 'Missing cipher key from item field';
      change(null, status: RxStatus.error(message));

      return UIUtils.showSimpleDialog(
        'Cipher Key Not Found',
        message,
      );
    }

    // decrypt vault
    late Uint8List cipherKey;

    try {
      cipherKey = base64Decode(fields_.first.data.value!);
    } catch (e) {
      const message = 'Cipher key is broken or tampered';
      change(null, status: RxStatus.error(message));

      return UIUtils.showSimpleDialog(
        'Cipher Key Is Broken',
        message,
      );
    }

    final correctCipherKey = await CipherService.to.canDecrypt(
      result.right,
      cipherKey,
    );

    if (!correctCipherKey) {
      const message = 'Cipher key is incorrect';
      change(null, status: RxStatus.error(message));

      return UIUtils.showSimpleDialog(
        'Failed To Decrypt',
        message,
      );
    }

    final decryptedFile = await CipherService.to.decryptFile(
      result.right,
      cipherKey: cipherKey,
    );

    // parse vault
    final vaultString = await decryptedFile.readAsString();
    final vaultJson = jsonDecode(vaultString);
    // deserialize
    final importedItems = List<HiveLisoItem>.from(
      vaultJson.map((x) => HiveLisoItem.fromJson(x)),
    );

    console.info('imported items: ${importedItems.length}');
    data.value = importedItems;

    change(null, status: data.isEmpty ? RxStatus.empty() : RxStatus.success());

    // import vault
  }

  void search() {
    //
  }
}
