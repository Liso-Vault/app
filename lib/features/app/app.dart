import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:liso/core/translations/data.dart';
import 'package:liso/features/app/pages.dart';
import 'package:liso/features/app/routes.dart';
import 'package:liso/features/general/unknown.screen.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../core/firebase/analytics.service.dart';
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
      inputDecoratorUnfocusedHasBorder: true,
      inputDecoratorIsFilled: false,
      inputDecoratorRadius: 5,
      inputDecoratorBorderType: FlexInputBorderType.underline,
      inputDecoratorUnfocusedBorderIsColored: false,
    );

    // MATERIAL APP
    return GetMaterialApp(
      navigatorObservers: [
        if (!GetPlatform.isWindows) ...[
          AnalyticsService.to.observer,
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
      getPages: AppPages.routes,
      defaultTransition: Transition.native,
      // transitionDuration: 200.milliseconds,
      // THEME MODE
      themeMode: ThemeMode.values.byName(persistence.theme.val),
      // DARK THEME
      darkTheme: FlexColorScheme.dark(
        fontFamily: 'Lato',
        scheme: FlexScheme.green,
        colors: FlexSchemeColor.from(primary: kAppColor),
        visualDensity: VisualDensity.compact,
        appBarElevation: 0.3,
        subThemesData: subThemes,
        onSurface: Colors.grey.shade500, // popupmenu background color
        scaffoldBackground: const Color(0xFF161616),
        background: const Color(0xFF1C1C1C), // drawer background color
      ).toTheme,
      // LIGHT THEME
      theme: FlexColorScheme.light(
        fontFamily: 'Lato',
        scheme: FlexScheme.green,
        colors: FlexSchemeColor.from(primary: kAppColorDarker),
        appBarStyle: FlexAppBarStyle.background,
        appBarElevation: 0.3,
        visualDensity: VisualDensity.compact,
        subThemesData: subThemes,
        onPrimary: Colors.white, // button text color
      ).toTheme,
      // UNKNOWN ROUTE FALLBACK SCREEN
      unknownRoute: GetPage(
        name: Routes.unknown,
        page: () => const UnknownScreen(),
      ),
    );
  }
}
