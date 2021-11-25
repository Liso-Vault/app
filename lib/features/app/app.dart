import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/translations/data.dart';
import 'package:liso/features/app/pages.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/general/unknown.screen.dart';
import 'package:liso/features/main/main_screen.binding.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PersistenceController persistence = Get.find();

    // MATERIAL APP
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // LOCALE
      translationsKeys: translationKeys,
      locale: Locale(persistence.localeCode.val),
      fallbackLocale: const Locale('en', 'US'),
      // NAVIGATION
      initialRoute: Routes.main,
      initialBinding: MainScreenBinding(),
      getPages: AppPages.routes,
      defaultTransition: Transition.native,
      transitionDuration: 200.milliseconds,
      // THEMING
      darkTheme: FlexColorScheme.dark(
        scheme: FlexScheme.blue,
      ).toTheme, // dark
      themeMode: ThemeMode.dark,
      // UNKNOWN ROUTE FALLBACK SCREEN
      unknownRoute: GetPage(
        name: Routes.unknown,
        page: () => const UnknownScreen(),
      ),
    );
  }
}
