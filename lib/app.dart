import 'package:chitchat/common/theme/default.dart';
import 'package:chitchat/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class ChitChatApp extends StatelessWidget {
  final Client client;
  final VoIP voip;

  const ChitChatApp({
    required this.client,
    required this.voip,
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

    return MultiProvider(
      providers: [
        Provider<Client>(create: (context) => client),
        Provider<VoIP>(create: (context) => voip),
      ],
      child: MaterialApp(
        title: 'ChitChat',
        theme: defaultTheme(context),
        debugShowCheckedModeBanner: false,
        home: SplashScreen(client: client),
      ),
    );
  }
}
