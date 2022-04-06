import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/controllers/persistence.controller.dart';
import 'package:liso/core/translations/data.dart';
import 'package:liso/features/app/pages.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/general/unknown.screen.dart';

import '../../core/utils/globals.dart';
import '../main/main_screen.controller.dart';

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
      defaultTransition: Transition.rightToLeft,
      transitionDuration: 250.milliseconds,
      // THEME MODE
      themeMode: ThemeMode.values.byName(persistence.theme.val),
      // DARK THEME
      darkTheme: FlexColorScheme.dark(
        scheme: FlexScheme.green,
        colors: FlexSchemeColor.from(primary: kAppColor),
        // scaffoldBackground: const Color(0xFF161616),
      ).toTheme,
      // LIGHT THEME
      theme: FlexColorScheme.light(
        scheme: FlexScheme.green,
        colors: FlexSchemeColor.from(primary: kAppColorDarker),
        appBarBackground: Colors.grey.shade100,
      ).toTheme,
      // UNKNOWN ROUTE FALLBACK SCREEN
      unknownRoute: GetPage(
        name: Routes.unknown,
        page: () => const UnknownScreen(),
      ),
    );
  }
}
