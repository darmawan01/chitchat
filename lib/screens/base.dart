import 'dart:developer';

import 'package:chitchat/screens/history.dart';
import 'package:chitchat/screens/login.dart';
import 'package:chitchat/screens/profile.dart';
import 'package:chitchat/screens/rooms.dart';
import 'package:chitchat/utils/utils.dart';
import 'package:chitchat/widgets/contacts_modal.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final _pageCtrl = PageController(initialPage: 1);
  int _page = 1;

  List<Widget> screens = const [
    Center(child: HistoryScreen()),
    Center(child: RoomsScreen()),
    Center(child: ProfileScreen()),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl.addListener(() {
      setState(() {
        _page = _pageCtrl.page?.toInt() ?? 1;
      });
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: 0,
                    onTap: _contacts,
                    leading: const Icon(Icons.contacts_rounded),
                    title: const Text('Contract'),
                  ),
                ),
                PopupMenuItem<String>(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: 0,
                    onTap: _logout,
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Logout'),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageCtrl,
        children: screens,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  _pageCtrl.jumpToPage(0);
                },
                icon: Icon(
                  Icons.history,
                  size: 30,
                  color: _page == 0 ? Colors.blueAccent : Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {
                  _pageCtrl.jumpToPage(2);
                },
                icon: Icon(
                  Icons.person_2_outlined,
                  size: 30,
                  color: _page == 2 ? Colors.blueAccent : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: InkWell(
        onTap: () {
          _pageCtrl.jumpToPage(1);
        },
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: _page == 1 ? Colors.blueAccent : Colors.black,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.emoji_people_outlined,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _contacts() {
    showTransparentModalBottomSheet(
      context,
      (context) => const ContactsModal(),
    );
  }

  void _logout() async {
    final client = Provider.of<Client>(context, listen: false);

    try {
      await client.logout();
    } catch (e) {
      log(e.toString());
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    });
  }
}
