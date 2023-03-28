import 'dart:convert';

import 'package:chitchat/models/quick_call.dart';
import 'package:chitchat/screens/room.dart';
import 'package:chitchat/utils/utils.dart';
import 'package:chitchat/widgets/incoming_call_modal.dart';
import 'package:chitchat/widgets/room_modal.dart';
import 'package:chitchat/widgets/video_call_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:matrix/matrix.dart';
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
      body: Column(
        children: [
          Container(
            height: 35,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.blue),
              ),
            ),
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _directChat,
                  child: Text(
                    "Direct Message",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.blue),
                  ),
                ),
                TextButton(
                  onPressed: _newGroup,
                  child: Text(
                    "New Group",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.blue),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: client.onSync.stream,
              builder: (context, _) => ListView.builder(
                itemCount: client.rooms.length,
                itemBuilder: (context, i) {
                  final room = client.rooms[i];

                  final lastEvent = room.lastEvent;
                  if (lastEvent != null &&
                      lastEvent.text.contains("signal") &&
                      !lastEvent.redacted &&
                      lastEvent.senderId != client.userID &&
                      lastEvent.relationshipEventId == null) {
                    final signal = QuickCall.fromJson(
                      jsonDecode(lastEvent.calcLocalizedBodyFallback(
                        const MatrixDefaultLocalizations(),
                        hideReply: true,
                      )),
                    );

                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            flex: 1,
                            onPressed: (context) async {
                              await room.sendTextEvent(
                                  jsonEncode(
                                    QuickCall(signal: QuickCallSignal.rejected)
                                        .toJson(),
                                  ),
                                  inReplyTo: lastEvent);
                            },
                            foregroundColor: Colors.red,
                            label: 'Reject',
                          ),
                          SlidableAction(
                            flex: 1,
                            onPressed: (context) async {
                              await room.sendTextEvent(
                                  jsonEncode(
                                    QuickCall(signal: QuickCallSignal.accepted)
                                        .toJson(),
                                  ),
                                  inReplyTo: lastEvent);
                            },
                            foregroundColor: Colors.blue,
                            label: 'Accept',
                          ),
                        ],
                      ),
                      child: Card(
                        child: Container(
                          color: signal.isEmergencyCall
                              ? Colors.red
                              : Colors.yellow,
                          child: ListTile(
                            leading: Icon(
                              signal.isEmergencyCall
                                  ? Icons.emergency_outlined
                                  : Icons.emoji_people_outlined,
                              size: 35,
                            ),
                            title: Text(room.getLocalizedDisplayname()),
                            subtitle: Text(
                              DateFormat("m/d/yyyy h:mm a").format(
                                lastEvent.originServerTs,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          flex: 1,
                          onPressed: (context) async {
                            showConfirmDialog(context).then((value) async {
                              if (value) {
                                await room.leave();
                              }
                            });
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
                              room.getLocalizedDisplayname(),
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
                        (lastEvent?.text.isNotEmpty ?? false) &&
                                lastEvent?.relationshipEventId == null
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
          ),
        ],
      ),
    );
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

  void _directChat() {
    showTransparentModalBottomSheet(
      context,
      (context) => const CreateRoomBottomSheet(
        title: 'Chat Someone',
        type: SheetType.room,
        buttonLabel: 'Send',
        direct: true,
      ),
    );
  }

  void _newGroup() {
    showTransparentModalBottomSheet(
      context,
      (context) => const CreateRoomBottomSheet(
        title: 'New Room',
        type: SheetType.room,
        buttonLabel: 'Create',
      ),
    );
  }
}
