import 'package:chitchat/providers/page_prov.dart';
import 'package:chitchat/screens/rooms.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> screens = const [
    Center(child: Text("History")),
    Center(child: Text("Profile")),
    Center(child: RoomsScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    final pageProv = Provider.of<PageProvider>(context);
    return Scaffold(
      body: screens[pageProv.pageinit],
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  // pageProv.setPage(0);
                },
                icon: Icon(
                  Icons.history,
                  size: 25,
                  color:
                      pageProv.pageinit == 0 ? Colors.blueAccent : Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {
                  // pageProv.setPage(1);
                },
                icon: Icon(
                  Icons.person,
                  size: 25,
                  color:
                      pageProv.pageinit == 1 ? Colors.blueAccent : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: InkWell(
        onTap: () {
          pageProv.setPage(2);
        },
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: pageProv.pageinit == 2 ? Colors.blueAccent : Colors.black,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.call,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
