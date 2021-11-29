import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:liso/core/liso/liso_paths.dart';
import 'package:liso/core/notifications/notifications.manager.dart';

import 'core/controllers/global.controller.dart';
import 'core/controllers/persistence.controller.dart';
import 'core/hive/hive.manager.dart';
import 'features/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // setup window size for desktop
  _setupWindowSize();
  // init Liso paths
  await LisoPaths.init();
  // init Hive
  await HiveManager.init();
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

  // const size = Size(950, 1400); // desktop size
  const size = Size(400, 900); // phone size
  await DesktopWindow.setWindowSize(size);
  await DesktopWindow.setMinWindowSize(size);
}
