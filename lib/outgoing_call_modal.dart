import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class OutGoingCallWidget extends StatefulWidget {
  final CallSession? session;

  const OutGoingCallWidget({super.key, this.session});

  @override
  State<OutGoingCallWidget> createState() => _OutGoingCallWidgetState();
}

class _OutGoingCallWidgetState extends State<OutGoingCallWidget> {
  bool micMuted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: widget.session?.onCallStateChanged.stream,
          builder: (context, snapshot) {
            return Stack(
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
                          "${widget.session?.remoteUser?.calcDisplayname()}"[0]
                              .toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.session?.remoteUser?.calcDisplayname() ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (snapshot.data != CallState.kConnected)
                  Positioned(
                    bottom: 120,
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        backgroundColor: Colors.red,
                        child: const Icon(
                          Icons.call_end,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () {
                          widget.session?.hangup();
                        },
                      ),
                      if (snapshot.data == CallState.kConnected)
                        FloatingActionButton(
                          onPressed: () {
                            setState(() => micMuted = !micMuted);

                            widget.session?.setMicrophoneMuted(micMuted);
                          },
                          backgroundColor:
                              micMuted ? Colors.grey : Colors.green,
                          child: Icon(
                            micMuted ? Icons.mic_off : Icons.mic,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }
}
