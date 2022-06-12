import 'package:get/get.dart';
import 'package:liso/features/cipher/cipher_screen.controller.dart';
import 'package:liso/features/create_password/create_password_screen.controller.dart';
import 'package:liso/features/debug/debug.screen.dart';
import 'package:liso/features/devices/devices_screen.controller.dart';
import 'package:liso/features/otp/otp_screen.controller.dart';
import 'package:liso/features/restore/restore_screen.controller.dart';
import 'package:liso/features/s3/provider/custom_provider_screen.controller.dart';
import 'package:liso/features/seed/seed_screen.controller.dart';
import 'package:liso/features/shared_vaults/shared_vaults_screen.controller.dart';
import 'package:liso/features/wallet/wallet_screen.controller.dart';

import '../../core/form_fields/password.field.dart';
import '../about/about_screen.controller.dart';
import '../attachments/attachments_screen.controller.dart';
import '../drawer/drawer_widget.controller.dart';
import '../groups/groups.controller.dart';
import '../groups/groups_screen.controller.dart';
import '../item/item_screen.controller.dart';
import '../joined_vaults/explorer/vault_explorer_screen.controller.dart';
import '../joined_vaults/joined_vaults_screen.controller.dart';
import '../password_generator/password_generator_screen.controller.dart';
import '../s3/explorer/s3_content_tile.controller.dart';
import '../s3/explorer/s3_exporer_screen.controller.dart';
import '../seed/generator/seed_generator_screen.controller.dart';
import '../settings/settings_screen.controller.dart';
import '../upgrade/upgrade_screen.controller.dart';
import 'main_screen.controller.dart';

class MainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainScreenController(), permanent: true);
    Get.put(DrawerMenuController(), permanent: true);
    // WIDGETS
    Get.create(() => PasswordFormFieldController());
    Get.create(() => S3ContentTileController());
    Get.create(() => ChipsInputController());
    // Re-inject controllers when in Desktop
    // SCREENS
    Get.lazyPut(() => ItemScreenController(), fenix: true);
    Get.lazyPut(() => AttachmentsScreenController(), fenix: true);
    Get.lazyPut(() => SettingsScreenController(), fenix: true);
    Get.lazyPut(() => AboutScreenController(), fenix: true);
    Get.lazyPut(() => UpgradeScreenController(), fenix: true);
    Get.lazyPut(() => OTPScreenController(), fenix: true);
    Get.lazyPut(() => GroupsScreenController(), fenix: true);
    Get.lazyPut(() => SharedVaultsScreenController(), fenix: true);
    Get.lazyPut(() => JoinedVaultsScreenController(), fenix: true);
    Get.lazyPut(() => VaultExplorerScreenController(), fenix: true);
    Get.lazyPut(() => DevicesScreenController(), fenix: true);
    Get.lazyPut(() => SeedScreenController(), fenix: true);
    Get.lazyPut(() => SeedGeneratorScreenController(), fenix: true);
    Get.lazyPut(() => PasswordGeneratorScreenController(), fenix: true);
    Get.lazyPut(() => RestoreScreenController(), fenix: true);
    Get.lazyPut(() => CreatePasswordScreenController(), fenix: true);
    // CONTROLLERS
    Get.lazyPut(() => GroupsController(), fenix: true);
    // S3
    Get.lazyPut(() => S3ExplorerScreenController(), fenix: true);
    Get.lazyPut(() => CustomSyncProviderScreenController(), fenix: true);
    // WALLET
    Get.lazyPut(() => WalletScreenController(), fenix: true);
    // CIPHER
    Get.lazyPut(() => CipherScreenController(), fenix: true);
  }
}
