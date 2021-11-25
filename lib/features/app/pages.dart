import 'package:get/get.dart';
import 'package:liso/features/about/about.screen.dart';
import 'package:liso/features/about/about_screen.controller.dart';
import 'package:liso/features/create_password/create_password.screen.dart';
import 'package:liso/features/create_password/create_password_screen.controller.dart';
import 'package:liso/features/export/export.screen.dart';
import 'package:liso/features/export/export_screen.controller.dart';
import 'package:liso/features/import/import.screen.dart';
import 'package:liso/features/import/import_screen.controller.dart';
import 'package:liso/features/reset/reset.screen.dart';
import 'package:liso/features/reset/reset_screen.controller.dart';
import 'package:liso/features/seed/seed.screen.dart';
import 'package:liso/features/seed/seed_screen.controller.dart';
import 'package:liso/features/main/main.screen.dart';
import 'package:liso/features/main/main_screen.binding.dart';
import 'package:liso/features/settings/settings.screen.dart';
import 'package:liso/features/settings/settings_screen.controller.dart';
import 'package:liso/features/unlock/unlock.screen.dart';
import 'package:liso/features/unlock/unlock_screen.controller.dart';
import 'package:liso/features/welcome/welcome.screen.dart';
import 'package:liso/features/welcome/welcome_screen.controller.dart';

import 'routes.dart';

class AppPages {
  static const initial = Routes.main;

  static final routes = [
    GetPage(
      name: Routes.main,
      page: () => const MainScreen(),
      binding: MainScreenBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.welcome,
      page: () => const WelcomeScreen(),
      binding: WelcomeScreenBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.createPassword,
      page: () => const CreatePasswordScreen(),
      binding: CreatePasswordScreenBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.unlock,
      page: () => const UnlockScreen(),
      binding: UnlockScreenBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.reset,
      page: () => const ResetScreen(),
      binding: ResetScreenBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.seed,
      page: () => const SeedScreen(),
      binding: SeedScreenBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.import,
      page: () => const ImportScreen(),
      binding: ImportScreenBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.export,
      page: () => const ExportScreen(),
      binding: ExportScreenBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsScreenBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.about,
      page: () => const AboutScreen(),
      binding: AboutScreenBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
