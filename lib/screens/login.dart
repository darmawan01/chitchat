import 'dart:io';

import 'package:chitchat/screens/base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _homeserver = "3.27.93.95";
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;
  bool _isRegister = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * .3,
            child: Card(
              child: Container(
                width: MediaQuery.of(context).size.height * .40,
                height: 350,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Login",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 30,
                            color: Colors.blue,
                          ),
                    ),
                    const SizedBox(height: 34),
                    TextField(
                      controller: _usernameCtrl,
                      readOnly: _loading,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordCtrl,
                      readOnly: _loading,
                      autocorrect: false,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      alignment: Alignment.centerRight,
                      child: RichText(
                        text: TextSpan(
                          text: _isRegister
                              ? "Have an account ? "
                              : "New account ? ",
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: _isRegister
                                  ? " login here"
                                  : " register here",
                              recognizer:
                                  _loading ? null : TapGestureRecognizer()
                                    ?..onTap = () {
                                      setState(() {
                                        _isRegister = !_isRegister;
                                      });
                                    },
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.lightBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _auth,
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator.adaptive(),
                              )
                            : Text(_isRegister ? 'Register' : 'Login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _auth() async {
    setState(() {
      _loading = true;
    });

    try {
      final client = Provider.of<Client>(context, listen: false);

      await client.checkHomeserver(Uri.http("$_homeserver:8008", ''));

      if (_isRegister) {
        await client.register(
            username: _usernameCtrl.text,
            password: _passwordCtrl.text,
            auth: AuthenticationData(type: AuthenticationTypes.dummy),
            initialDeviceDisplayName:
                'ChitChat ${Platform.operatingSystem}${kReleaseMode ? '' : 'Debug'}');
      } else {
        await client.login(LoginType.mLoginPassword,
            password: _passwordCtrl.text,
            identifier: AuthenticationUserIdentifier(user: _usernameCtrl.text),
            initialDeviceDisplayName:
                'ChitChat ${Platform.operatingSystem}${kReleaseMode ? '' : 'Debug'}');
      }

      await client.setDisplayName(
        client.userID!,
        _usernameCtrl.text,
      );

      Future.delayed(const Duration(milliseconds: 100), () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const BaseScreen()),
          (route) => false,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
      setState(() {
        _loading = false;
      });
    }
  }
}
