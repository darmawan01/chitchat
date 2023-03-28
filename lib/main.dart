import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:chitchat/app.dart';
import 'package:chitchat/models/quick_call.dart';
// import 'package:chitchat/models/event.dart';
import 'package:chitchat/services/notification.dart';
import 'package:chitchat/services/voip.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:matrix/matrix.dart';
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
    logLevel: kReleaseMode ? Level.warning : Level.verbose,
  );

  await client.init();

  client.onEvent.stream.listen((event) {
    final room = client.getRoomById(event.roomID);
    final e = Event.fromJson(event.content, room!);

    if (e.senderId != client.userID && e.type == EventTypes.Message) {
      var body = e.calcLocalizedBodyFallback(
        const MatrixDefaultLocalizations(),
        hideReply: true,
      );

      if (e.text.contains("signal")) {
        final signal = QuickCall.fromJson(
          jsonDecode(e.calcLocalizedBodyFallback(
            const MatrixDefaultLocalizations(),
            hideReply: true,
          )),
        );

        body = signal.toMessage(e.senderFromMemoryOrFallback.calcDisplayname());
      }

      FlutterBackgroundService().invoke(
        "message",
        {"title": e.senderFromMemoryOrFallback.calcDisplayname(), "body": body},
      );

      // if (Platform.isIOS) {
      //   NotificationService().showNotification(
      //     title: e.sender,
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
