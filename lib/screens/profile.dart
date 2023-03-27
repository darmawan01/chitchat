import 'dart:developer';

import 'package:chitchat/screens/login.dart';
import 'package:chitchat/utils/utils.dart';
import 'package:chitchat/widgets/contacts_modal.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 250.0,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF3366FF),
                  Color(0xFF00CCFF),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                CircleAvatar(
                  radius: 50.0,
                  backgroundColor: Colors.grey,
                ),
                SizedBox(height: 10.0),
                Text(
                  'Avatar Title',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.contacts),
                    title: const Text('Contact'),
                    onTap: () => _contacts(context),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About'),
                    onTap: () {
                      // handle about app menu item tap
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: const Text('Logout'),
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _contacts(BuildContext context) {
    showTransparentModalBottomSheet(
      context,
      (context) => const ContactsModal(),
    );
  }

  void _logout(BuildContext context) async {
    final client = Provider.of<Client>(context, listen: false);

    showConfirmDialog(
      context,
      title: "Logout",
      content: const Text("Are you sure want to logout ?"),
    ).then((ok) async {
      if (ok) {
        await client.logout();

        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        });
      }
    }).catchError((e) {
      log(e.toString());
    });
  }
}
