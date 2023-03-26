import 'dart:io';

import 'package:chitchat/screens/base.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
  final _homeserverCtrl = TextEditingController(text: "3.27.93.95");
  final _usernameCtrl =
      TextEditingController(text: Platform.isAndroid ? 'opapa' : 'omama');
  final _passwordCtrl = TextEditingController(text: 'Test@1234');

  bool _loading = false;
  bool _isRegister = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _homeserverCtrl,
              readOnly: _loading,
              autocorrect: false,
              decoration: const InputDecoration(
                prefixText: 'http://',
                border: OutlineInputBorder(),
                labelText: 'Homeserver',
              ),
            ),
            const SizedBox(height: 16),
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
                      : "Not have an account yet ? ",
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: _isRegister ? " login here" : " register here",
                      recognizer: _loading ? null : TapGestureRecognizer()
                        ?..onTap = () {
                          setState(() {
                            _isRegister = !_isRegister;
                          });
                        },
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    );
  }

  void _auth() async {
    setState(() {
      _loading = true;
    });

    try {
      final client = Provider.of<Client>(context, listen: false);

      await client.checkHomeserver(
        Uri.http("${_homeserverCtrl.text.trim()}:8008", ''),
      );

      if (_isRegister) {
        final deviceInfoPlugin = DeviceInfoPlugin();
        final deviceInfo = await deviceInfoPlugin.deviceInfo;

        await client.register(
          username: _usernameCtrl.text,
          password: _passwordCtrl.text,
          auth: AuthenticationData(type: AuthenticationTypes.dummy),
          deviceId: deviceInfo.data.tryGet("model"),
          kind: AccountKind.user,
        );
      } else {
        await client.login(
          LoginType.mLoginPassword,
          password: _passwordCtrl.text,
          identifier: AuthenticationUserIdentifier(user: _usernameCtrl.text),
        );
      }

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
