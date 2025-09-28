import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/services/main.service.dart';
import 'package:app_core/widgets/unknown.screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart' show DefaultCupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:liso/core/translations/data.dart';
import 'package:liso/features/app/flex_theme.dart';
import 'package:liso/features/app/pages.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    initGlobalsWithContext(context);

    final locales = translationKeys.entries.map((e) {
      if (e.key.contains('_')) {
        final splitted = e.key.split('_');
        return Locale(splitted[0], splitted[1]);
      }

      return Locale(e.key);
    });

    final localizationDelegates = const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      // Flutter Quill
      DefaultCupertinoLocalizations.delegate,
      DefaultMaterialLocalizations.delegate,
      DefaultWidgetsLocalizations.delegate,
      FlutterQuillLocalizations.delegate,
    ];

    darkThemeData = AppTheme.dark;
    final persistence = Get.find<Persistence>();

    // MATERIAL APP
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // LOCALE
      translationsKeys: translationKeys,
      locale: Locale(persistence.localeCode.val),
      fallbackLocale: const Locale('en'),
      localizationsDelegates: localizationDelegates,
      supportedLocales: locales,
      // NAVIGATION
      initialRoute: Routes.main,
      getPages: Pages.data,
      defaultTransition: Transition.native,
      // THEME MODE
      themeMode: ThemeMode.values.byName(persistence.theme.val),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // UNKNOWN ROUTE FALLBACK SCREEN
      unknownRoute: GetPage(
        name: Routes.unknown,
        page: () => const UnknownScreen(),
      ),
      onReady: () {
        // initialize initial theme value
        MainService.to.dark.value = Get.theme.brightness == Brightness.dark;
      },
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
    );
  }
}
