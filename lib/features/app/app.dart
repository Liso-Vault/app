import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/services/main.service.dart';
import 'package:app_core/widgets/unknown.screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/translations/data.dart';
import 'package:liso/features/app/pages.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final persistence = Get.find<Persistence>();
    const scheme = FlexScheme.jungle;
    const buttonStyle = ButtonStyle(visualDensity: VisualDensity.standard);

    const subThemes = FlexSubThemesData(
      fabUseShape: false,
      thinBorderWidth: 0.2,
      thickBorderWidth: 0.5,
      inputDecoratorRadius: 15,
      inputDecoratorUnfocusedHasBorder: false,
      popupMenuRadius: 10,
    );

    final darkThemeBase = FlexColorScheme.dark(
      // darkIsTrueBlack: true,
      useMaterial3: true,
      scheme: scheme,
      subThemesData: subThemes,
    ).toTheme;

    final darkTheme = darkThemeBase.copyWith(
      // textTheme: GoogleFonts.interTextTheme(darkThemeBase.textTheme),
      elevatedButtonTheme: const ElevatedButtonThemeData(style: buttonStyle),
      outlinedButtonTheme: const OutlinedButtonThemeData(style: buttonStyle),
    );

    final lightThemeBase = FlexColorScheme.light(
      // lightIsWhite: false,
      useMaterial3: true,
      scheme: scheme,
      subThemesData: subThemes,
      appBarStyle: FlexAppBarStyle.background,
    ).toTheme;

    final lightTheme = lightThemeBase.copyWith(
      // textTheme: GoogleFonts.interTextTheme(lightThemeBase.textTheme),
      elevatedButtonTheme: const ElevatedButtonThemeData(style: buttonStyle),
      outlinedButtonTheme: const OutlinedButtonThemeData(style: buttonStyle),
    );

    // MATERIAL APP
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // THEME MODE
      themeMode: ThemeMode.values.byName(persistence.theme.val),
      darkTheme: darkTheme, // dark theme
      theme: lightTheme, // light theme
      onReady: () {
        // initialize initial theme value
        MainService.to.dark.value = Get.theme.brightness == Brightness.dark;
      },
      navigatorObservers: [
        if (!isWindowsLinux) ...[
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
        ] else ...[
          // SentryNavigatorObserver(),
        ]
      ],
      // NAVIGATION
      initialRoute: Routes.main,
      getPages: Pages.data,
      defaultTransition: Transition.native,
      // UNKNOWN ROUTE FALLBACK SCREEN
      unknownRoute: GetPage(
        name: Routes.unknown,
        page: () => const UnknownScreen(),
      ),
      // LOCALE
      translationsKeys: translationKeys,
      locale: Locale(persistence.localeCode.val),
      fallbackLocale: const Locale('en'),
      supportedLocales: translationKeys.entries.map((e) {
        if (e.key.contains('_')) {
          final splitted = e.key.split('_');
          return Locale(splitted[0], splitted[1]);
        }

        return Locale(e.key);
      }),
    );
  }
}
