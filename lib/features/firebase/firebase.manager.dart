import 'package:firebase_core/firebase_core.dart';
import 'package:liso/core/utils/console.dart';

import 'crashlytics.manager.dart';

class FirebaseAppManager {
  static final console = Console(name: 'FirebaseAppManager');

  // VARIABLES

  // GETTERS

  // FUNCTIONS

  static Future<void> init() async {
    await Firebase.initializeApp();
    CrashlyticsManager.init();
    console.info('init');
  }
}
