import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/widgets/unknown.screen.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/translations/data.dart';
import 'package:liso/features/app/pages.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../core/utils/globals.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final persistence = Get.find<Persistence>();

    const subThemes = FlexSubThemesData(
      fabUseShape: false,
      thinBorderWidth: 0.2,
      thickBorderWidth: 0.5,
      inputDecoratorRadius: 15,
      inputDecoratorUnfocusedHasBorder: false,
      popupMenuRadius: 15,
      dialogRadius: 10,
    );

    const scheme = FlexScheme.jungle;

    // MATERIAL APP
    return GetMaterialApp(
      navigatorObservers: [
        if (!isWindowsLinux) ...[
          FirebaseAnalyticsObserver(
            analytics: FirebaseAnalytics.instance,
          ),
        ] else ...[
          SentryNavigatorObserver(),
        ]
      ],
      debugShowCheckedModeBanner: false,
      // showPerformanceOverlay: true,
      // LOCALE
      translationsKeys: translationKeys,
      locale: Locale(persistence.localeCode.val),
      fallbackLocale: const Locale('en', 'US'),
      // NAVIGATION
      initialRoute: Routes.main,
      getPages: Pages.data,
      defaultTransition: Transition.native,
      themeMode: ThemeMode.values.byName(persistence.theme.val),
      // DARK THEME
      darkTheme: FlexColorScheme.dark(
        scheme: scheme,
        colors: FlexSchemeColor.from(primary: kAppColor),
        subThemesData: subThemes,
        background: const Color(0xFF1C1C1C), // drawer background color
      ).toTheme,
      // LIGHT THEME
      theme: FlexColorScheme.light(
        scheme: scheme,
        colors: FlexSchemeColor.from(primary: const Color(0xFF00A465)),
        appBarElevation: GetPlatform.isDesktop ? 0 : 2.0,
        appBarStyle: FlexAppBarStyle.background,
        subThemesData: subThemes,
      ).toTheme,
      // UNKNOWN ROUTE FALLBACK SCREEN
      unknownRoute: GetPage(
        name: Routes.unknown,
        page: () => const UnknownScreen(),
      ),
    );
  }
}
