import 'package:get/get.dart';
import 'package:liso/features/about/about.screen.dart';
import 'package:liso/features/about/about_screen.controller.dart';
import 'package:liso/features/create_password/create_password.screen.dart';
import 'package:liso/features/create_password/create_password_screen.controller.dart';
import 'package:liso/features/export/export.screen.dart';
import 'package:liso/features/export/export_screen.controller.dart';
import 'package:liso/features/google/sign_in.screen.dart';
import 'package:liso/features/google/sign_in_screen.controller.dart';
import 'package:liso/features/import/import.screen.dart';
import 'package:liso/features/import/import_screen.controller.dart';
import 'package:liso/features/ipfs/ipfs.screen.dart';
import 'package:liso/features/ipfs/ipfs_screen.controller.dart';
import 'package:liso/features/main/main.screen.dart';
import 'package:liso/features/mnemonic/confirm/confirm_mnemonic.screen.dart';
import 'package:liso/features/mnemonic/confirm/confirm_mnemonic_screen.controller.dart';
import 'package:liso/features/mnemonic/mnemonic.screen.dart';
import 'package:liso/features/mnemonic/mnemonic_screen.controller.dart';
import 'package:liso/features/reset/reset.screen.dart';
import 'package:liso/features/reset/reset_screen.controller.dart';
import 'package:liso/features/settings/settings.screen.dart';
import 'package:liso/features/settings/settings_screen.controller.dart';
import 'package:liso/features/unlock/unlock.screen.dart';
import 'package:liso/features/unlock/unlock_screen.controller.dart';
import 'package:liso/features/welcome/welcome.screen.dart';
import 'package:liso/features/welcome/welcome_screen.controller.dart';

import '../../core/middlewares/authentication.middleware.dart';
import '../ipfs/explorer/ipfs_explorer.screen.dart';
import '../ipfs/explorer/ipfs_exporer_screen.controller.dart';
import '../item/item.screen.dart';
import '../item/item_screen.controller.dart';
import '../main/main_screen.controller.dart';
import 'routes.dart';

class AppPages {
  static const initial = Routes.main;

  static final routes = [
    GetPage(
      name: Routes.main,
      page: () => MainScreen(),
      binding: MainScreenBinding(),
      transition: Transition.fadeIn,
      middlewares: [AuthenticationMiddleware()],
    ),
    GetPage(
      name: Routes.welcome,
      page: () => const WelcomeScreen(),
      binding: WelcomeScreenBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.signIn,
      page: () => const SignInScreen(),
      binding: SignInScreenBinding(),
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
    // IPFS
    GetPage(
      name: Routes.ipfs,
      page: () => const IPFSScreen(),
      binding: IPFSScreenBinding(),
    ),
    GetPage(
      name: Routes.ipfsExplorer,
      page: () => const IPFSExplorerScreen(),
      binding: IPFSExplorerScreenBinding(),
    ),
  ];
}
