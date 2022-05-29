import 'package:get/get.dart';
import 'package:liso/features/cipher/cipher_screen.controller.dart';
import 'package:liso/features/otp/otp_screen.controller.dart';
import 'package:liso/features/s3/provider/sync_provider_screen.controller.dart';
import 'package:liso/features/shared_vaults/shared_vaults_screen.controller.dart';
import 'package:liso/features/wallet/wallet_screen.controller.dart';

import '../../core/form_fields/password.field.dart';
import '../../core/form_fields/pin.field.dart';
import '../about/about_screen.controller.dart';
import '../attachments/attachments_screen.controller.dart';
import '../drawer/drawer_widget.controller.dart';
import '../export/export_screen.controller.dart';
import '../item/item_screen.controller.dart';
import '../reset/reset_screen.controller.dart';
import '../s3/explorer/s3_content_tile.controller.dart';
import '../s3/explorer/s3_exporer_screen.controller.dart';
import '../settings/settings_screen.controller.dart';
import '../shared_vaults/shared_vault.controller.dart';
import '../upgrade/upgrade_screen.controller.dart';
import '../vaults/vaults.controller.dart';
import '../vaults/vaults_screen.controller.dart';
import 'main_screen.controller.dart';

class MainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainScreenController(), permanent: true);
    Get.put(DrawerMenuController(), permanent: true);
    // WIDGETS
    Get.lazyPut(() => PasswordFormFieldController(), fenix: true);
    Get.lazyPut(() => PINFormFieldController(), fenix: true);
    // Re-inject controllers when in Desktop
    // SCREENS
    Get.lazyPut(() => ItemScreenController(), fenix: true);
    Get.lazyPut(() => AttachmentsScreenController(), fenix: true);
    Get.lazyPut(() => SettingsScreenController(), fenix: true);
    Get.lazyPut(() => AboutScreenController(), fenix: true);
    Get.lazyPut(() => ExportScreenController(), fenix: true);
    Get.lazyPut(() => ResetScreenController(), fenix: true);
    Get.lazyPut(() => UpgradeScreenController(), fenix: true);
    Get.lazyPut(() => OTPScreenController(), fenix: true);
    Get.lazyPut(() => VaultsScreenController(), fenix: true);
    Get.lazyPut(() => SharedVaultsScreenController(), fenix: true);
    Get.lazyPut(() => SharedVaultsController(), fenix: true);
    Get.lazyPut(() => VaultsController(), fenix: true);
    // S3
    Get.lazyPut(() => S3ExplorerScreenController(), fenix: true);
    Get.lazyPut(() => SyncProviderScreenController(), fenix: true);
    Get.create(() => S3ContentTileController());
    // WALLET
    Get.lazyPut(() => WalletScreenController(), fenix: true);
    // CIPHER
    Get.lazyPut(() => CipherScreenController(), fenix: true);
  }
}
