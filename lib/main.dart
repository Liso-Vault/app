import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/controllers/global.controller.dart';
import 'core/controllers/persistence.controller.dart';
import 'core/hive/hive.manager.dart';
import 'core/liso/liso_paths.dart';
import 'core/notifications/notifications.manager.dart';
import 'features/app/app.dart';
import 'features/firebase/firebase.manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // improve performance
  GestureBinding.instance?.resamplingEnabled = true;
  // setup window size for desktop
  _setupWindowSize();
  // init Liso paths
  await LisoPaths.init();
  // init Hive
  await HiveManager.init();
  // init Firebase
  await FirebaseAppManager.init();
  // init GetStorage
  await GetStorage.init();
  // init NotificationManager
  NotificationsManager.init();

  // Initialize Top Controllers
  Get.put(PersistenceController());
  Get.put(GlobalController());

  runApp(const App());
}

void _setupWindowSize() async {
  if (!GetPlatform.isDesktop || GetPlatform.isWeb) return;
  await DesktopWindow.setWindowSize(const Size(700, 850));
  await DesktopWindow.setMinWindowSize(const Size(400, 850));
}
