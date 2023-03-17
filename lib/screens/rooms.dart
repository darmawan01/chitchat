import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix_poc/screens/login.dart';
import 'package:matrix_poc/screens/room.dart';
import 'package:matrix_poc/utils/utils.dart';
import 'package:matrix_poc/widgets/contacts_modal.dart';
import 'package:matrix_poc/widgets/floating_action_button.dart';
import 'package:matrix_poc/widgets/incoming_call_modal.dart';
import 'package:matrix_poc/widgets/video_call_modal.dart';
import 'package:provider/provider.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({Key? key}) : super(key: key);

  @override
  RoomsScreenState createState() => RoomsScreenState();
}

class RoomsScreenState extends State<RoomsScreen> {
  @override
  Widget build(BuildContext context) {
    final client = Provider.of<Client>(context, listen: false);
    final voip = Provider.of<VoIP>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      voip.onIncomingCall.stream.listen((event) {
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            useSafeArea: false,
            builder: (context) => event.type == CallType.kVoice
                ? IncomingCallWidget(session: event)
                : VideoCallWidget(session: event),
          );
        }

        event.onCallStateChanged.stream.listen((state) {
          if (state == CallState.kEnded && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Rooms'),
        centerTitle: false,
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
      body: StreamBuilder(
        stream: client.onSync.stream,
        builder: (context, _) => ListView.builder(
          itemCount: client.rooms.length,
          itemBuilder: (context, i) {
            final room = client.rooms[i];
            final myHost = client.userID?.split(":")[1];

            return Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    flex: 1,
                    onPressed: (context) async {
                      
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete_forever,
                    label: 'Delete',
                  ),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  foregroundImage: room.avatar == null
                      ? null
                      : NetworkImage(
                          room.avatar!
                              .getThumbnail(
                                client,
                                width: 56,
                                height: 56,
                              )
                              .toString(),
                        ),
                  child: room.avatar == null
                      ? Text(
                          client.rooms[i]
                              .getLocalizedDisplayname()[0]
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        room
                            .getLocalizedDisplayname()
                            .replaceAll(":$myHost", ""),
                      ),
                    ),
                    if (room.notificationCount > 0)
                      Material(
                        borderRadius: BorderRadius.circular(99),
                        color: Colors.red,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            room.notificationCount.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      )
                  ],
                ),
                subtitle: Text(
                  room.lastEvent?.text.isNotEmpty ?? false
                      ? room.lastEvent!.text
                      : 'No messages',
                  maxLines: 1,
                ),
                onTap: () => _join(client.rooms[i]),
              ),
            );
          },
        ),
      ),
      floatingActionButton: const CustomFloatingActionButton(),
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

  void _join(Room room) async {
    if (room.membership != Membership.join) {
      await room.join();
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RoomScreen(room: room),
        ),
      );
    });
  }
}
