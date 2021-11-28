import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:liso/core/utils/console.dart';

class NotificationsManager {
  static final plugin = FlutterLocalNotificationsPlugin();
  static final console = Console(name: 'NotificationsManager');

  static void cancel(int id) => plugin.cancel(id);
  static void cancelAll() => plugin.cancelAll();

  static void init() async {
    _initPlugin();
    console.info("init");
  }

  static void _initPlugin() {
    const iosSettings = IOSInitializationSettings(
      onDidReceiveLocalNotification: onForegroundPayload,
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const androidSettings = AndroidInitializationSettings('ic_notification');

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onSelectNotification: onBackgroundPayload,
    );

    console.info("_initPlugin");
  }

  static void notify({
    final int id = 0,
    required final String title,
    required final String body,
  }) async {
    console.info("notify...");

    const androidDetails = AndroidNotificationDetails(
      "general",
      "General",
      channelDescription: "General Notifications",
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = IOSNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await plugin.show(
      id,
      title,
      body,
      details,
      payload: '',
    );

    console.info("done");
  }

  static void onBackgroundPayload(String? payload) async {
    console.info('onBackgroundPayload payload: ' + payload!);
  }

  static void onForegroundPayload(
      int? id, String? title, String? body, String? payload) async {
    console.info('onForegroundPayload payload: ' + payload!);
  }
}
