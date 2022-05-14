import 'package:get/get.dart';
import 'package:liso/features/cipher/cipher_screen.controller.dart';
import 'package:liso/features/wallet/assets/assets_screen.controller.dart';

import '../../core/form_fields/password.field.dart';
import '../../core/form_fields/pin.field.dart';
import '../about/about_screen.controller.dart';
import '../drawer/drawer_widget.controller.dart';
import '../export/export_screen.controller.dart';
import '../ipfs/explorer/ipfs_exporer_screen.controller.dart';
import '../ipfs/ipfs_screen.controller.dart';
import '../item/item_screen.controller.dart';
import '../reset/reset_screen.controller.dart';
import '../s3/explorer/s3_exporer_screen.controller.dart';
import '../settings/settings_screen.controller.dart';
import 'main_screen.controller.dart';

class MainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainScreenController(), permanent: true);
    Get.put(DrawerMenuController(), permanent: true);
    // WIDGETS
    Get.create(() => PasswordFormFieldController());
    Get.create(() => PINFormFieldController());
    // SCREENS
    Get.create(() => ItemScreenController());
    Get.create(() => SettingsScreenController());
    Get.create(() => AboutScreenController());
    Get.create(() => ExportScreenController());
    Get.create(() => ResetScreenController());
    // ipfs
    Get.create(() => IPFSScreenController());
    Get.create(() => IPFSExplorerScreenController());
    // S3
    Get.create(() => S3ExplorerScreenController());
    // WALLET
    Get.create(() => AssetsScreenController());
    // CIPHER
    Get.create(() => CipherScreenController());
  }
}
