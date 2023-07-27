import 'dart:convert';

import 'package:aptus_aware/models/quick_call.dart';
import 'package:aptus_aware/services/notification.dart';
import 'package:flutter/foundation.dart';
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';

class MatrixClient {
  static Future<Client> init() async {
    final client = Client(
      'Aptus Aware',
      databaseBuilder: (_) async {
        final dir = await getApplicationSupportDirectory();
        final db = HiveCollectionsDatabase('aptus_aware', dir.path);
        await db.open();
        return db;
      },
      logLevel: kReleaseMode ? Level.warning : Level.verbose,
    );

    await client.init();

    _listener(client);

    return Future.value(client);
  }

  static void _listener(Client client) {
    client.onEvent.stream.listen((event) {
      final room = client.getRoomById(event.roomID);

      final content = event.content;
      if (content["sender"] == null) content["sender"] = "";

      final e = Event.fromJson(content, room!);

      if (e.senderId != client.userID && e.type == EventTypes.Message) {
        var body = e.calcLocalizedBodyFallback(
          const MatrixDefaultLocalizations(),
          hideReply: true,
        );

        String quickSignal = "";
        if (e.text.contains("signal")) {
          final signal = QuickCall.fromJson(
            jsonDecode(e.calcLocalizedBodyFallback(
              const MatrixDefaultLocalizations(),
              hideReply: true,
            )),
          );

          body =
              signal.toMessage(e.senderFromMemoryOrFallback.calcDisplayname());
          quickSignal = signal.signal.toString();

          NotificationService().showNotification(
            title: e.senderFromMemoryOrFallback.calcDisplayname(),
            body: body,
            signal: quickSignal,
          );
        }
      }
    });
  }
}
