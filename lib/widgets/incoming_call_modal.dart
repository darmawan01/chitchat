import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class IncomingCallWidget extends StatefulWidget {
  final CallSession? session;

  const IncomingCallWidget({this.session, super.key});

  @override
  State<IncomingCallWidget> createState() => _IncomingCallWidgetState();
}

class _IncomingCallWidgetState extends State<IncomingCallWidget> {
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
                        (widget.session?.remoteUser?.displayName ?? "")[0]
                            .toUpperCase(),
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.session?.remoteUser?.displayName ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ...(!(snapshot.data == CallState.kConnected ||
                      snapshot.data == CallState.kEnded))
                  ? [
                      Positioned(
                        bottom: 50,
                        left: 50,
                        child: FloatingActionButton(
                          backgroundColor: Colors.green,
                          child: const Icon(
                            Icons.call,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            widget.session?.answer();
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        right: 50,
                        child: FloatingActionButton(
                          backgroundColor: Colors.red,
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            widget.session?.reject();
                          },
                        ),
                      ),
                    ]
                  : [
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
            ],
          );
        },
      ),
    );
  }
}
