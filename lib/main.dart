import 'dart:async';import 'dart:io';
import 'dart:ui';

import 'package:aptus_aware/app.dart';
import 'package:aptus_aware/services/matrix.dart';
import 'package:aptus_aware/services/notification.dart';
import 'package:aptus_aware/utils/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = HTTPOverrides();

  await NotificationService().init();
  await initializeService();
  final client = await MatrixClient.init();

  runApp(AptusAwareApp(client: client));
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  AndroidNotificationChannel channel = AndroidNotificationChannel(
    NotificationService.foregroundNotificationId.toString(),
    'MY FOREGROUND SERVICE', 
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: NotificationService.foregroundNotificationId.toString(), // this must match with notification channel you created above.
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: NotificationService.foregroundNotificationId,
    )
  );
}

Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    NotificationService().showNotification();
  });
}