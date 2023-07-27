import 'package:aptus_aware/screens/base.dart';
import 'package:aptus_aware/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class SplashScreen extends StatefulWidget {
  final Client client;
  const SplashScreen({super.key, required this.client});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _init();
  }

  _init() {
    Future.delayed(const Duration(milliseconds: 3000), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => widget.client.isLogged()
              ? const BaseScreen()
              : const LoginScreen(),
        ),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
              width: 120,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/aptus-logo.png"))),
            ),
          ],
        ),
      ),
    );
  }
}
