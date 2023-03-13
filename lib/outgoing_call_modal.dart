import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class OutGoingCallWidget extends StatelessWidget {
  final CallSession? session;

  const OutGoingCallWidget({super.key, this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.blue[500],
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Text(
                    "${session?.remoteUser?.calcDisplayname()}"[0]
                        .toUpperCase(),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  session?.remoteUser?.calcDisplayname() ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder(
            stream: session?.onCallStateChanged.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == CallState.kConnected) {
                return Container();
              }

              return Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    snapshot.data == CallState.kEnded
                        ? 'Ended...'
                        : 'Ringing...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              child: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () {
                session?.hangup().catchError((err) {
                  log(err.toString());
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
