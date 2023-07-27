import 'dart:io';

import 'package:aptus_aware/app.dart';
import 'package:aptus_aware/services/matrix.dart';
import 'package:aptus_aware/services/notification.dart';
import 'package:aptus_aware/utils/http.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = HTTPOverrides();

  await NotificationService().init();
  final client = await MatrixClient.init();

  runApp(AptusAwareApp(client: client));
}
