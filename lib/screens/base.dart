import 'package:aptus_aware/screens/history.dart';
import 'package:aptus_aware/screens/profile.dart';
import 'package:aptus_aware/screens/rooms/rooms.dart';
import 'package:aptus_aware/utils/consts.dart';
import 'package:flutter/material.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final _pageCtrl = PageController(initialPage: 1);
  int _page = 1;

  List<Widget> screens = [
    const Center(child: HistoryScreen()),
    const Center(child: RoomsScreen()),
    const Center(child: ProfileScreen()),
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
      body: SafeArea(
        child: PageView(
          controller: _pageCtrl,
          children: screens,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  _pageCtrl.jumpToPage(0);
                },
                icon: Icon(
                  Icons.history,
                  size: 30,
                  color: _page == 0 ? Colorized.primary : Colors.black45,
                ),
              ),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  _pageCtrl.jumpToPage(2);
                },
                icon: Icon(
                  Icons.person_2_outlined,
                  size: 30,
                  color: _page == 2 ? Colorized.primary : Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: InkWell(
        enableFeedback: false,
        onTap: () {
          _pageCtrl.jumpToPage(1);
        },
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: _page == 1 ? Colorized.primary : Colors.grey,
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
}
