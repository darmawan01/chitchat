import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix_poc/models/event.dart';
import 'package:matrix_poc/utils/utils.dart';
import 'package:matrix_poc/widgets/incoming_call_modal.dart';
import 'package:matrix_poc/widgets/outgoing_call_modal.dart';
import 'package:matrix_poc/widgets/room_modal.dart';
import 'package:matrix_poc/widgets/video_call_modal.dart';
import 'package:provider/provider.dart';

class RoomScreen extends StatefulWidget {
  final Room room;
  const RoomScreen({required this.room, Key? key}) : super(key: key);

  @override
  RoomScreenState createState() => RoomScreenState();
}

class RoomScreenState extends State<RoomScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _sendController = TextEditingController();
  late final Future<Timeline> _timelineFuture;

  @override
  void initState() {
    _timelineFuture = widget.room.getTimeline(
      onChange: (i) {
        _listKey.currentState?.setState(() {});
      },
      onInsert: (i) async {
        _listKey.currentState?.insertItem(i);
      },
      onRemove: (i) {
        _listKey.currentState?.removeItem(i, (_, __) => const ListTile());
      },
    );
    super.initState();
  }

  Widget messageItem(Event event, Timeline timeline, bool isMe) {
    final isAvatarAvailable =
        event.senderFromMemoryOrFallback.avatarUrl != null;
    final avatar = CircleAvatar(
      foregroundImage: isAvatarAvailable
          ? NetworkImage(
              event.senderFromMemoryOrFallback.avatarUrl!
                  .getThumbnail(
                    widget.room.client,
                    width: 56,
                    height: 56,
                  )
                  .toString(),
            )
          : null,
      child: isAvatarAvailable
          ? null
          : Text(
              event.senderFromMemoryOrFallback
                  .calcDisplayname()[0]
                  .toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );

    final title = Text(
      event.senderFromMemoryOrFallback.calcDisplayname(),
      style: Theme.of(context).textTheme.titleMedium,
    );

    final time = Text(
      DateFormat("m/d/yyyy h:mm a").format(
        event.originServerTs,
      ),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            avatar,
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: MediaQuery.of(context).size.width * .65,
            child: GestureDetector(
              onLongPress: () {
                _showOptions(context, event).then((value) {
                  switch (value) {
                    case "D":
                      event.redactEvent();
                      break;
                    case "C":
                      Clipboard.setData(
                        ClipboardData(
                          text: event.getDisplayEvent(timeline).body,
                        ),
                      );
                      break;
                    default:
                  }
                });
              },
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: title,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.getDisplayEvent(timeline).text,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment:
                            isMe ? Alignment.centerLeft : Alignment.centerRight,
                        child: time,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            avatar,
          ],
        ],
      ),
    );
  }

  Future _showOptions(BuildContext context, Event event) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: SizedBox(
            height: MediaQuery.of(context).size.height * .24,
            width: MediaQuery.of(context).size.height * 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Seen By",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16.0),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: event.receipts.length,
                  itemBuilder: (context, index) {
                    final receip = event.receipts[index];

                    return CupertinoListTile(
                      title: Text(receip.user.displayName ?? ""),
                      subtitle: Text(
                        DateFormat("MMM d, yyyy h:mm a").format(receip.time),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text("Copy"),
              onPressed: () {
                Navigator.pop(context, "C");
              },
            ),
            CupertinoDialogAction(
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context, "D");
              },
            )
          ],
        );
      },
    );
  }

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
          if (state == CallState.kEnded) {
            Navigator.pop(context);
          }
        });
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.room.getLocalizedDisplayname().split(":")[0],
        ),
        centerTitle: false,
        leadingWidth: 32,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: StreamBuilder(
            stream: client.onEvent.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final e = Events.fromJson(snapshot.data!.content);

                if (e.isTypingEvent &&
                    e.content!.userIds!.isNotEmpty &&
                    !e.content!.userIds!.contains(client.userID)) {
                  return Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * .12,
                        bottom: 2.2),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${e.content?.cleanedUserIds} is typing...",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  );
                }
              }

              return Container();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call_rounded),
            onPressed: () async {
              final call = await voip.inviteToCall(
                widget.room.id,
                CallType.kVideo,
              );

              call.onCallEventChanged.stream.listen((event) {
                if (event == CallEvent.kHangup && Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              });

              Future.delayed(
                const Duration(milliseconds: 500),
                () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    useSafeArea: false,
                    builder: (context) => VideoCallWidget(session: call),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call_rounded),
            onPressed: () async {
              final call = await voip.inviteToCall(
                widget.room.id,
                CallType.kVoice,
              );

              call.onCallEventChanged.stream.listen((event) {
                if (event == CallEvent.kHangup && Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              });

              Future.delayed(
                const Duration(milliseconds: 500),
                () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    useSafeArea: false,
                    builder: (context) => OutGoingCallWidget(session: call),
                  );
                },
              );
            },
          ),
          if (!widget.room.isDirectChat && widget.room.canInvite)
            IconButton(
              icon: const Icon(Icons.supervisor_account_rounded),
              onPressed: () {
                showTransparentModalBottomSheet(
                  context,
                  (context) => CreateRoomBottomSheet(
                    title: "Invite someone",
                    type: SheetType.invite,
                    buttonLabel: "Send",
                    roomId: widget.room.id,
                  ),
                );
              },
            ),
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    horizontalTitleGap: 0,
                    onTap: () {
                      showConfirmDialog(context, ).then((value) async {
                        if (value) {
                          await widget.room.leave();

                          Future.delayed(const Duration(milliseconds: 500), () {
                            Navigator.pop(context);
                          });
                        }
                      });
                    },
                    title: Text(
                      'Leave room',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: FutureBuilder<Timeline>(
                    future: _timelineFuture,
                    builder: (context, snapshot) {
                      final timeline = snapshot.data;
                      if (timeline == null) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }

                      final events = timeline.events;

                      return Column(
                        children: [
                          Center(
                            child: TextButton(
                              onPressed: timeline.requestHistory,
                              child: const Text('Load more...'),
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: AnimatedList(
                              key: _listKey,
                              reverse: true,
                              initialItemCount: events.length,
                              itemBuilder: (context, i, animation) {
                                final event = events[i];
                                final isMe = event.senderId == client.userID;

                                if (event.roomId != null &&
                                    !event.redacted &&
                                    !isMe) {
                                  client.postReceipt(
                                    event.roomId!,
                                    ReceiptType.mRead,
                                    event.eventId,
                                    {},
                                  );
                                }

                                if (event.type == EventTypes.CallInvite &&
                                    event.senderId != client.userID) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.phone_missed,
                                          size: 24,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(width: 6.0),
                                        Text(
                                            "Missed call from ${event.senderFromMemoryOrFallback.calcDisplayname()}"),
                                      ],
                                    ),
                                  );
                                }

                                return event.relationshipEventId != null ||
                                        event.redacted ||
                                        event
                                            .getDisplayEvent(timeline)
                                            .text
                                            .isEmpty
                                    ? Container()
                                    : ScaleTransition(
                                        scale: animation,
                                        child: Opacity(
                                          opacity:
                                              event.status.isSent ? 1 : 0.5,
                                          child: messageItem(
                                            event,
                                            timeline,
                                            isMe,
                                          ),
                                        ),
                                      );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _sendController,
                          decoration: const InputDecoration(
                            hintText: 'Send message',
                          ),
                          onChanged: (value) {
                            widget.room.setTyping(true, timeout: 500);
                          },
                          onSubmitted: (value) {
                            widget.room.setTyping(false, timeout: 500);
                          },
                          onTapOutside: (event) {
                            widget.room.setTyping(false, timeout: 500);
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send_outlined),
                        onPressed: _send,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _send() {
    widget.room.sendTextEvent(_sendController.text.trim());
    _sendController.clear();
  }
}
