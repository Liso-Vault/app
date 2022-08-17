import 'package:get/get.dart';
import 'package:liso/features/about/about.screen.dart';
import 'package:liso/features/beta/disabled_beta.screen.dart';
import 'package:liso/features/create_password/create_password.screen.dart';
import 'package:liso/features/debug/debug.screen.dart';
import 'package:liso/features/main/main.screen.dart';
import 'package:liso/features/restore/restore.screen.dart';
import 'package:liso/features/seed/seed.screen.dart';
import 'package:liso/features/settings/settings.screen.dart';
import 'package:liso/features/shared_vaults/shared_vaults.screen.dart';
import 'package:liso/features/unlock/unlock.screen.dart';
import 'package:liso/features/welcome/welcome.screen.dart';

import '../../core/middlewares/authentication.middleware.dart';
import '../attachments/attachments.screen.dart';
import '../categories/categories.screen.dart';
import '../cipher/cipher.screen.dart';
import '../devices/devices.screen.dart';
import '../feedback/feedback.screen.dart';
import '../groups/groups.screen.dart';
import '../items/item.screen.dart';
import '../joined_vaults/explorer/vault_explorer.screen.dart';
import '../joined_vaults/joined_vaults.screen.dart';
import '../otp/otp.screen.dart';
import '../password_generator/password_generator.screen.dart';
import '../s3/explorer/s3_explorer.screen.dart';
import '../s3/provider/custom_provider_screen.dart';
import '../s3/provider/sync_provider.screen.dart';
import '../seed/generator/seed_generator.screen.dart';
import '../pro/upgrade/upgrade.screen.dart';
import '../wallet/wallet.screen.dart';
import 'routes.dart';

class AppPages {
  static const initial = Routes.main;

  static final routes = [
    GetPage(
      name: Routes.main,
      page: () => MainScreen(),
      middlewares: [
        AuthenticationMiddleware(),
      ],
    ),
    GetPage(
      name: Routes.welcome,
      page: () => const WelcomeScreen(),
    ),
    GetPage(
      name: Routes.unlock,
      page: () => const UnlockScreen(),
    ),
    GetPage(
      name: Routes.createPassword,
      page: () => const CreatePasswordScreen(),
    ),
    GetPage(
      name: Routes.passwordGenerator,
      page: () => const PasswordGeneratorScreen(),
    ),
    GetPage(
      name: Routes.item,
      page: () => const ItemScreen(),
    ),
    GetPage(
      name: Routes.restore,
      page: () => const RestoreScreen(),
    ),
    GetPage(
      name: Routes.seed,
      page: () => const SeedScreen(),
    ),
    GetPage(
      name: Routes.seedGenerator,
      page: () => const SeedGeneratorScreen(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsScreen(),
    ),
    GetPage(
      name: Routes.about,
      page: () => const AboutScreen(),
    ),
    GetPage(
      name: Routes.syncProvider,
      page: () => const SyncProviderScreen(),
    ),
    GetPage(
      name: Routes.customSyncProvider,
      page: () => const CustomSyncProviderScreen(),
    ),
    GetPage(
      name: Routes.s3Explorer,
      page: () => const S3ExplorerScreen(),
    ),
    GetPage(
      name: Routes.attachments,
      page: () => const AttachmentsScreen(),
    ),
    GetPage(
      name: Routes.wallet,
      page: () => const WalletScreen(),
    ),
    GetPage(
      name: Routes.cipher,
      page: () => const CipherScreen(),
    ),
    GetPage(
      name: Routes.upgrade,
      preventDuplicates: true,
      page: () => const UpgradeScreen(),
    ),
    GetPage(
      name: Routes.otp,
      page: () => const OTPScreen(),
    ),
    GetPage(
      name: Routes.categories,
      page: () => const CategoriesScreen(),
      preventDuplicates: true,
    ),
    GetPage(
      name: Routes.vaults,
      page: () => const GroupsScreen(),
      preventDuplicates: true,
    ),
    GetPage(
      name: Routes.sharedVaults,
      page: () => const SharedVaultsScreen(),
      preventDuplicates: true,
    ),
    GetPage(
      name: Routes.joinedVaults,
      page: () => const JoinedVaultsScreen(),
      preventDuplicates: true,
    ),
    GetPage(
      name: Routes.vaultExplorer,
      page: () => const VaultExplorerScreen(),
      preventDuplicates: true,
    ),
    GetPage(
      name: Routes.devices,
      page: () => const DevicesScreen(),
      preventDuplicates: true,
    ),
    GetPage(
      name: Routes.feedback,
      page: () => const FeedbackScreen(),
      preventDuplicates: true,
    ),
    GetPage(
      name: Routes.disabledBeta,
      page: () => const DisabledBetaScreen(),
      preventDuplicates: true,
    ),
    GetPage(
      name: Routes.debug,
      page: () => const DebugScreen(),
      preventDuplicates: true,
    ),
  ];
}
