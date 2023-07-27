import 'package:aptus_aware/common/theme/default.dart';
import 'package:aptus_aware/screens/splash.dart';
import 'package:aptus_aware/services/voip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class AptusAwareApp extends StatelessWidget {
  final Client client;

  const AptusAwareApp({
    required this.client,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    final voip = VoIP(client, VoipService());

    return MultiProvider(
      providers: [
        Provider<Client>(create: (context) => client),
        Provider<VoIP>(create: (context) => voip),
      ],
      child: MaterialApp(
        title: 'AptusAware',
        theme: defaultTheme(context),
        debugShowCheckedModeBanner: false,
        home: SplashScreen(client: client),
      ),
    );
  }
}
