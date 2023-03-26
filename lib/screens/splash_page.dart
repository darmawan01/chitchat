import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:chitchat/screens/login.dart';
import 'package:chitchat/screens/main_page.dart';

class SplashPage extends StatefulWidget {
  final Client client;
  const SplashPage({super.key, required this.client});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() {
    Future.delayed(const Duration(milliseconds: 3000), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              widget.client.isLogged() ? const MainPage() : const LoginScreen(),
        ),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FlutterLogo(),
      ),
    );
  }
}
