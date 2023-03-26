import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:chitchat/screens/login.dart';
import 'package:chitchat/screens/rooms.dart';
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
    final theme = Theme.of(context).copyWith(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        color: Colors.blue,
        elevation: 0,
        toolbarTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return MultiProvider(
      providers: [
        Provider<Client>(create: (context) => client),
        Provider<VoIP>(create: (context) => voip)
      ],
      child: MaterialApp(
        title: 'ChitChat App',
        theme: theme,
        home: client.isLogged() ? const RoomsScreen() : const LoginScreen(),
      ),
    );
  }
}
