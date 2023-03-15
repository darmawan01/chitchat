import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:matrix/matrix.dart';

class VideoCallWidget extends StatefulWidget {
  final CallSession? session;

  const VideoCallWidget({super.key, this.session});

  @override
  State<VideoCallWidget> createState() => _VideoCallWidgetState();
}

class _VideoCallWidgetState extends State<VideoCallWidget> {
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  bool micMuted = false;
  bool videoMuted = false;

  @override
  initState() {
    super.initState();
    initRenderers();
  }

  initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  @override
  deactivate() {
    super.deactivate();

    localRenderer.dispose();
    remoteRenderer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        localRenderer.setSrcObject(
            stream: widget.session?.localUserMediaStream?.stream);
        remoteRenderer.setSrcObject(
            stream: widget.session?.remoteUserMediaStream?.stream);
      });
    });

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: widget.session?.onCallStreamsChanged.stream,
          builder: (context, session) {
            return OrientationBuilder(
              builder: (context, orientation) {
                return Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: RTCVideoView(
                        remoteRenderer,
                        placeholderBuilder: (context) {
                          return Container(
                            color: Colors.black,
                            child: Center(
                              child: Text(
                                'Connecting ...',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          );
                        },
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.white, width: 1.0),
                        ),
                        child: RTCVideoView(
                          localRenderer,
                          mirror: true,
                          placeholderBuilder: (context) {
                            return Container(color: Colors.black);
                          },
                          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,

                        ),
                      ),
                    ),
                    StreamBuilder(
                        stream: session.data?.onCallStateChanged.stream,
                        builder: (context, callState) {
                          return Positioned(
                            bottom: 50,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FloatingActionButton(
                                  onPressed: () {
                                    if (callState.data ==
                                            CallState.kConnected ||
                                        !(widget.session?.isRinging ?? false)) {
                                      widget.session?.hangup();
                                    } else {
                                      widget.session?.reject();
                                    }
                                  },
                                  backgroundColor: Colors.red,
                                  child: const Icon(Icons.call_end),
                                ),
                                if ((widget.session?.isRinging ?? false) &&
                                    callState.data != CallState.kConnected)
                                  FloatingActionButton(
                                    onPressed: () {
                                      widget.session?.answer();
                                    },
                                    backgroundColor: Colors.green,
                                    child: const Icon(Icons.call),
                                  ),
                                FloatingActionButton(
                                  onPressed: () {
                                    setState(() => micMuted = !micMuted);
                                    
                                    session.data?.setMicrophoneMuted(micMuted);
                                  },
                                  backgroundColor:
                                      micMuted ? Colors.grey : Colors.green,
                                  child: Icon(
                                    micMuted ? Icons.mic_off : Icons.mic,
                                  ),
                                ),
                                FloatingActionButton(
                                  onPressed: () {
                                    setState(() => videoMuted = !videoMuted);

                                    session.data
                                        ?.setLocalVideoMuted(videoMuted);
                                  },
                                  backgroundColor:
                                      videoMuted ? Colors.grey : Colors.green,
                                  child: Icon(
                                    videoMuted
                                        ? Icons.videocam_off
                                        : Icons.videocam,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
