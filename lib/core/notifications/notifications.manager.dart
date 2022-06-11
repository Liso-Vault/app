import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:liso/core/persistence/persistence.dart';
import 'package:console_mixin/console_mixin.dart';

class NotificationsManager {
  static final plugin = FlutterLocalNotificationsPlugin();
  static final console = Console(name: 'NotificationsManager');

  static void cancel(int id) => plugin.cancel(id);
  static void cancelAll() => plugin.cancelAll();

  static void init() async {
    const iosSettings = IOSInitializationSettings(
      onDidReceiveLocalNotification: onForegroundPayload,
    );

    const macosSettings = MacOSInitializationSettings();
    const androidSettings = AndroidInitializationSettings('ic_notification');

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    await plugin.initialize(
      onSelectNotification: onBackgroundPayload,
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: macosSettings,
      ),
    );

    console.info("init");
  }

  static void notify({
    required final String title,
    required final String body,
    String payload = '',
  }) async {
    const iosDetails = IOSNotificationDetails();
    const macosDetails = MacOSNotificationDetails();
    const linuxDetails = LinuxNotificationDetails();

    const androidDetails = AndroidNotificationDetails(
      "general",
      "General",
      channelDescription: "General Notifications",
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macosDetails,
      linux: linuxDetails,
    );

    await plugin.show(
      Persistence.to.notificationId.val++,
      title,
      body,
      details,
      payload: payload,
    );

    console.info('notified');
  }

  static void onBackgroundPayload(String? payload) async {
    console.info('onBackgroundPayload payload: ${payload!}');
  }

  static void onForegroundPayload(
    int? id,
    String? title,
    String? body,
    String? payload,
  ) async {
    console.info('onForegroundPayload payload: ${payload!}');
  }
}
