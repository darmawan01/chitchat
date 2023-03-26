import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:chitchat/screens/login.dart';
import 'package:chitchat/screens/base.dart';

class SplashScreen extends StatefulWidget {
  final Client client;
  const SplashScreen({super.key, required this.client});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
            const Icon(
              Icons.chat_outlined,
              size: 65,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              "ChitChat",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            )
          ],
        ),
      ),
    );
  }
}
