import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix_poc/app.dart';
import 'package:matrix_poc/event.dart';
import 'package:matrix_poc/notif_service.dart';
import 'package:matrix_poc/voip_service.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  await NotificationService().init();

  final client = Client(
    'Matrix Example Chat',
    databaseBuilder: (_) async {
      final dir = await getApplicationSupportDirectory();
      final db = HiveCollectionsDatabase('matrix_example_chat', dir.path);
      await db.open();
      return db;
    },
  );

  await client.init();

  client.onEvent.stream.listen((event) {
    final e = Events.fromJson(event.content);

    if (e.sender != client.userID && e.isEventMessage) {
      FlutterBackgroundService().invoke(
        "message",
        {"title": "Matrix POC", "body": e.content?.body ?? ""},
      );

      // if (Platform.isIOS) {
      //   NotificationService().showNotification(
      //     title: "Matrix POC",
      //     body: e.content?.body ?? "",
      //   );
      // }
    }
  });

  final voip = VoIP(client, VoipService());

  runApp(ChitChatApp(
    client: client,
    voip: voip,
  ));
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  service.on("message").listen((event) {
    NotificationService().showNotification(
      title: event?["title"],
      body: event?["body"],
    );
  });

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  service.on("message").listen((event) {
    NotificationService().showNotification(
      title: event?["title"],
      body: event?["body"],
    );
  });
}
