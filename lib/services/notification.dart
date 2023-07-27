import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {
  static const defaultChannel = AndroidNotificationChannel(
    "DEFAULT",
    "DEDAULT",
    description: "Default notifications",
    importance: Importance.low,
  );

  static const lowAlertChannel = AndroidNotificationChannel(
    "LOW_ALERT",
    "LOW ALERT",
    description: "Low alert notifications",
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound("alert_0"),
  );

  static const mediumAlertChannel = AndroidNotificationChannel(
    "MEDIUM_ALERT",
    "MEDIUM ALERT",
    description: "Medium alert notifications",
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound("alert_1"),
  );

  static const hightAlertChannel = AndroidNotificationChannel(
    "HIGHT_ALERT",
    "HIGHT ALERT",
    description: "Hight alert notifications",
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound("alert_2"),
  );

  static const criticalAlertChannel = AndroidNotificationChannel(
    "CRITICAL_ALERT",
    "CRITICAL ALERT",
    description: "Critical alert notifications",
    importance: Importance.max,
    sound: RawResourceAndroidNotificationSound("alert_3"),
  );

  static final defaultNotifications = NotificationDetails(
    android: AndroidNotificationDetails(
      defaultChannel.id,
      defaultChannel.name,
      channelDescription: defaultChannel.description,
      importance: defaultChannel.importance,
      priority: Priority.high,
    ),
    iOS: const DarwinNotificationDetails(
      presentSound: true,
    ),
  );

  static final lowNotifications = NotificationDetails(
    android: AndroidNotificationDetails(
      defaultChannel.id,
      defaultChannel.name,
      channelDescription: defaultChannel.description,
      // sound: defaultChannel.sound,
      importance: defaultChannel.importance,
      priority: Priority.high,
    ),
    iOS: const DarwinNotificationDetails(
      presentSound: true,
      presentBadge: true,
      presentAlert: true,
    ),
  );

  static final mediumNotifications = NotificationDetails(
    android: AndroidNotificationDetails(
      mediumAlertChannel.id,
      mediumAlertChannel.name,
      channelDescription: mediumAlertChannel.description,
      // sound: mediumAlertChannel.sound,
      importance: mediumAlertChannel.importance,
      priority: Priority.high,
    ),
    iOS: const DarwinNotificationDetails(
      presentSound: true,
      presentBadge: true,
      presentAlert: true,
    ),
  );

  static final hightNotifications = NotificationDetails(
    android: AndroidNotificationDetails(
      hightAlertChannel.id,
      hightAlertChannel.name,
      channelDescription: hightAlertChannel.description,
      // sound: hightAlertChannel.sound,
      importance: hightAlertChannel.importance,
      priority: Priority.high,
    ),
    iOS: const DarwinNotificationDetails(
      presentSound: true,
      presentBadge: true,
      presentAlert: true,
    ),
  );

  static final maxNotifications = NotificationDetails(
    android: AndroidNotificationDetails(
      criticalAlertChannel.id,
      criticalAlertChannel.name,
      channelDescription: criticalAlertChannel.description,
      // sound: criticalAlertChannel.sound,
      importance: criticalAlertChannel.importance,
      priority: Priority.high,
    ),
    iOS: const DarwinNotificationDetails(
      presentSound: true,
      presentBadge: true,
      presentAlert: true,
    ),
  );

  Future<void> initAndroidChannels(
    FlutterLocalNotificationsPlugin notif,
  ) async {
    if (Platform.isAndroid) {
      notif
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission()
          .then((ok) {
        if (ok ?? false) {
          final channels = [
            Notifications.defaultChannel,
            Notifications.lowAlertChannel,
            Notifications.mediumAlertChannel,
            Notifications.hightAlertChannel,
            Notifications.criticalAlertChannel
          ];

          for (var chan in channels) {
            notif
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()
                ?.createNotificationChannel(chan);
          }
        }
      });
    }
  }
}

class NotificationService extends Notifications {
  static const foregroundNotificationId = 112233;

  final notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    initAndroidChannels(notifications);

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  void onDidReceiveNotificationResponse(NotificationResponse details) {}

  Future<void> showNotification({
    int id = foregroundNotificationId,
    String? title,
    String? body,
    String? payLoad,
    String? signal,
  }) async {
    var details = Notifications.defaultNotifications;

    if (signal?.isNotEmpty ?? false) {
      switch (signal) {
        case '567a37e1-1883-4e79-b2c4-9c66a812cae5':
          details = Notifications.maxNotifications;
          break;
        case '74507cd7-da24-40c6-9624-1891330aff88':
          details = Notifications.mediumNotifications;
          break;
        case 'c04fa10d-a93d-4d80-9d8e-31cfcc5d8532':
        case 'bb48dfe8-5ce1-4496-9f49-b70996b3e6d4':
        case '2beabed3-97f0-4a65-94ac-a9f7c3ad0e61':
          details = Notifications.lowNotifications;
          break;
      }
    }

    return notifications.show(
      id,
      title,
      body,
      details,
      payload: payLoad,
    );
  }
}
