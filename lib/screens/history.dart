import 'dart:convert';

import 'package:aptus_aware/models/quick_call.dart';
import 'package:aptus_aware/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final client = Provider.of<Client>(context, listen: false);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: client.onSync.stream,
              builder: (context, _) => ListView.builder(
                itemCount: client.rooms.length,
                itemBuilder: (context, i) {
                  final room = client.rooms[i];

                  return FutureBuilder<Timeline>(
                    future: room.getTimeline(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }

                      final events = snapshot.data?.events;

                      final signals = events
                          ?.where(
                            (item) =>
                                item.text.contains("signal") &&
                                item.senderId != client.userID,
                          )
                          .toList();

                      if (signals == null || signals.isEmpty) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * .75,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: room.requestHistory,
                                icon: const Icon(Icons.refresh),
                              ),
                              const Text("No data !")
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: signals.length,
                        shrinkWrap: true,
                        primary: true,
                        scrollDirection: Axis.vertical,
                        physics: const ScrollPhysics(),
                        itemBuilder: (context, index) {
                          final event = signals[index];
                          final signal = QuickCall.fromJson(
                            jsonDecode(
                              event.calcLocalizedBodyFallback(
                                const MatrixDefaultLocalizations(),
                                hideReply: true,
                              ),
                            ),
                          );

                          return Card(
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
                                  formatSinceTime(
                                    event.originServerTs
                                            .millisecondsSinceEpoch ~/
                                        1000,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontSize: 10),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
