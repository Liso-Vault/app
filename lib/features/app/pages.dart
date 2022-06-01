import 'package:get/get.dart';
import 'package:liso/features/about/about.screen.dart';
import 'package:liso/features/about/about_screen.controller.dart';
import 'package:liso/features/beta/disabled_beta.screen.dart';
import 'package:liso/features/beta/disabled_beta_screen.controller.dart';
import 'package:liso/features/create_password/create_password.screen.dart';
import 'package:liso/features/create_password/create_password_screen.controller.dart';
import 'package:liso/features/debug/debug.screen.dart';
import 'package:liso/features/export/export.screen.dart';
import 'package:liso/features/export/export_screen.controller.dart';
import 'package:liso/features/import/import.screen.dart';
import 'package:liso/features/import/import_screen.controller.dart';
import 'package:liso/features/main/main.screen.dart';
import 'package:liso/features/mnemonic/confirm/confirm_mnemonic.screen.dart';
import 'package:liso/features/mnemonic/confirm/confirm_mnemonic_screen.controller.dart';
import 'package:liso/features/mnemonic/mnemonic.screen.dart';
import 'package:liso/features/mnemonic/mnemonic_screen.controller.dart';
import 'package:liso/features/reset/reset.screen.dart';
import 'package:liso/features/reset/reset_screen.controller.dart';
import 'package:liso/features/settings/settings.screen.dart';
import 'package:liso/features/settings/settings_screen.controller.dart';
import 'package:liso/features/shared_vaults/shared_vaults.screen.dart';
import 'package:liso/features/shared_vaults/shared_vaults_screen.controller.dart';
import 'package:liso/features/unlock/unlock.screen.dart';
import 'package:liso/features/unlock/unlock_screen.controller.dart';
import 'package:liso/features/upgrade/upgrade_screen.controller.dart';
import 'package:liso/features/welcome/welcome.screen.dart';
import 'package:liso/features/welcome/welcome_screen.controller.dart';

import '../../core/middlewares/authentication.middleware.dart';
import '../Cipher/cipher_screen.controller.dart';
import '../attachments/attachments.screen.dart';
import '../attachments/attachments_screen.controller.dart';
import '../cipher/cipher.screen.dart';
import '../configuration/configuration.screen.dart';
import '../devices/devices.screen.dart';
import '../devices/devices_screen.controller.dart';
import '../item/item.screen.dart';
import '../item/item_screen.controller.dart';
import '../joined_vaults/explorer/vault_explorer.screen.dart';
import '../joined_vaults/explorer/vault_explorer_screen.controller.dart';
import '../joined_vaults/joined_vaults.screen.dart';
import '../joined_vaults/joined_vaults_screen.controller.dart';
import '../main/main_screen.bindings.dart';
import '../otp/otp.screen.dart';
import '../otp/otp_screen.controller.dart';
import '../s3/explorer/s3_explorer.screen.dart';
import '../s3/explorer/s3_exporer_screen.controller.dart';
import '../s3/provider/sync_provider_screen.controller.dart';
import '../s3/provider/sync_provider_screen.dart';
import '../syncing/syncing.screen.dart';
import '../syncing/syncing_screen.controller.dart';
import '../upgrade/upgrade.screen.dart';
import '../groups/groups.screen.dart';
import '../groups/groups_screen.controller.dart';
import '../wallet/wallet.screen.dart';
import '../wallet/wallet_screen.controller.dart';
import 'routes.dart';

class AppPages {
  static const initial = Routes.main;

  static final routes = [
    GetPage(
      name: Routes.main,
      page: () => MainScreen(),
      binding: MainScreenBinding(),
      transition: Transition.fadeIn,
      middlewares: [
        AuthenticationMiddleware(),
      ],
    ),
    GetPage(
      name: Routes.welcome,
      page: () => const WelcomeScreen(),
      binding: WelcomeScreenBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.unlock,
      page: () => const UnlockScreen(),
      binding: UnlockScreenBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.createPassword,
      page: () => const CreatePasswordScreen(),
      binding: CreatePasswordScreenBinding(),
    ),
    GetPage(
      name: Routes.reset,
      page: () => const ResetScreen(),
      binding: ResetScreenBinding(),
    ),
    GetPage(
      name: Routes.item,
      page: () => const ItemScreen(),
      binding: ItemScreenBinding(),
    ),
    GetPage(
      name: Routes.import,
      page: () => const ImportScreen(),
      binding: ImportScreenBinding(),
    ),
    GetPage(
      name: Routes.export,
      page: () => const ExportScreen(),
      binding: ExportScreenBinding(),
    ),
    GetPage(
      name: Routes.mnemonic,
      page: () => const MnemonicScreen(),
      binding: MnemonicScreenBinding(),
    ),
    GetPage(
      name: Routes.confirmMnemonic,
      page: () => const ConfirmMnemonicScreen(),
      binding: ConfirmMnemonicScreenBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsScreenBinding(),
    ),
    GetPage(
      name: Routes.about,
      page: () => const AboutScreen(),
      binding: AboutScreenBinding(),
    ),
    GetPage(
      name: Routes.configuration,
      page: () => const ConfigurationScreen(),
    ),
    GetPage(
      name: Routes.syncProvider,
      page: () => const SyncProviderScreen(),
      binding: SyncProviderScreenBinding(),
    ),
    GetPage(
      name: Routes.syncing,
      page: () => const SyncingScreen(),
      binding: SyncingScreenBinding(),
    ),
    GetPage(
      name: Routes.s3Explorer,
      page: () => const S3ExplorerScreen(),
      binding: S3ExplorerScreenBinding(),
    ),
    GetPage(
      name: Routes.attachments,
      page: () => const AttachmentsScreen(),
      binding: AttachmentsScreenBinding(),
    ),
    GetPage(
      name: Routes.wallet,
      page: () => const WalletScreen(),
      binding: WalletScreenBinding(),
    ),
    GetPage(
      name: Routes.cipher,
      page: () => const CipherScreen(),
      binding: CipherScreenBinding(),
    ),
    GetPage(
      name: Routes.upgrade,
      page: () => const UpgradeScreen(),
      binding: UpgradeScreenBinding(),
    ),
    GetPage(
      name: Routes.otp,
      page: () => const OTPScreen(),
      binding: OTPScreenBinding(),
    ),
    GetPage(
      name: Routes.vaults,
      page: () => const GroupsScreen(),
      binding: GroupsScreenBinding(),
    ),
    GetPage(
      name: Routes.sharedVaults,
      page: () => const SharedVaultsScreen(),
      binding: SharedVaultsScreenBinding(),
    ),
    GetPage(
      name: Routes.joinedVaults,
      page: () => const JoinedVaultsScreen(),
      binding: JoinedVaultsScreenBinding(),
    ),
    GetPage(
      name: Routes.vaultExplorer,
      page: () => const VaultExplorerScreen(),
      binding: VaultExplorerScreenBinding(),
    ),
    GetPage(
      name: Routes.devices,
      page: () => const DevicesScreen(),
      binding: DevicesScreenBinding(),
    ),
    GetPage(
      name: Routes.disabledBeta,
      page: () => const DisabledBetaScreen(),
      binding: DisabledBetaScreenBinding(),
    ),
    GetPage(
      name: Routes.debug,
      page: () => const DebugScreen(),
    ),
  ];
}
