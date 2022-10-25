import 'package:app_core/pages/feedback/feedback.screen.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/pages/update/update.screen.dart';
import 'package:app_core/pages/upgrade/upgrade.screen.dart';
import 'package:get/get.dart';
import 'package:liso/features/about/about.screen.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/create_password/create_password.screen.dart';
import 'package:liso/features/debug/debug.screen.dart';
import 'package:liso/features/import/import.screen.dart';
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
import '../categories/picker/category_picker.screen.dart';
import '../cipher/cipher.screen.dart';
import '../devices/devices.screen.dart';
import '../files/explorer/s3_explorer.screen.dart';
import '../groups/groups.screen.dart';
import '../items/item.screen.dart';
import '../joined_vaults/explorer/vault_explorer.screen.dart';
import '../joined_vaults/joined_vaults.screen.dart';
import '../otp/otp.screen.dart';
import '../password_generator/password_generator.screen.dart';
import '../seed/generator/seed_generator.screen.dart';
import '../wallet/wallet.screen.dart';

class Pages {
  static const initial = Routes.main;

  static final data = [
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
      name: AppRoutes.createPassword,
      page: () => const CreatePasswordScreen(),
    ),
    GetPage(
      name: AppRoutes.passwordGenerator,
      page: () => const PasswordGeneratorScreen(),
    ),
    GetPage(
      name: AppRoutes.item,
      page: () => const ItemScreen(),
    ),
    GetPage(
      name: AppRoutes.restore,
      page: () => const RestoreScreen(),
    ),
    GetPage(
      name: AppRoutes.import,
      page: () => const ImportScreen(),
    ),
    GetPage(
      name: AppRoutes.seed,
      page: () => const SeedScreen(),
    ),
    GetPage(
      name: AppRoutes.seedGenerator,
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
    // GetPage(
    //   name: Routes.syncProvider,
    //   page: () => const SyncProviderScreen(),
    // ),
    // GetPage(
    //   name: Routes.customSyncProvider,
    //   page: () => const CustomSyncProviderScreen(),
    // ),
    GetPage(
      name: AppRoutes.s3Explorer,
      page: () => const S3ExplorerScreen(),
    ),
    GetPage(
      name: AppRoutes.attachments,
      page: () => const AttachmentsScreen(),
    ),
    GetPage(
      name: AppRoutes.wallet,
      page: () => const WalletScreen(),
    ),
    GetPage(
      name: AppRoutes.cipher,
      page: () => const CipherScreen(),
    ),
    GetPage(
      name: Routes.upgrade,
      page: () => const UpgradeScreen(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OTPScreen(),
    ),
    GetPage(
      name: AppRoutes.categories,
      page: () => const CategoriesScreen(),
    ),
    GetPage(
      name: AppRoutes.categoryPicker,
      page: () => const CategoryPickerScreen(),
    ),
    GetPage(
      name: AppRoutes.vaults,
      page: () => const GroupsScreen(),
    ),
    GetPage(
      name: AppRoutes.sharedVaults,
      page: () => const SharedVaultsScreen(),
    ),
    GetPage(
      name: AppRoutes.joinedVaults,
      page: () => const JoinedVaultsScreen(),
    ),
    GetPage(
      name: AppRoutes.vaultExplorer,
      page: () => const VaultExplorerScreen(),
    ),
    GetPage(
      name: AppRoutes.devices,
      page: () => const DevicesScreen(),
    ),
    GetPage(
      name: Routes.feedback,
      page: () => const FeedbackScreen(),
    ),
    GetPage(
      name: Routes.update,
      page: () => const UpdateScreen(),
    ),
    GetPage(
      name: Routes.debug,
      page: () => const DebugScreen(),
    ),
  ];
}
