import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc_impl;
import 'package:matrix/matrix.dart';
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:webrtc_interface/src/mediadevices.dart';

class VoipService implements WebRTCDelegate {
  final player = AudioPlayer();

  @override
  Future<void> handleCallEnded(CallSession session) async {}

  @override
  bool get canHandleNewCall => true;

  @override
  Future<void> handleGroupCallEnded(GroupCall groupCall) async {}

  @override
  Future<void> handleMissedCall(CallSession session) async {}

  @override
  Future<void> handleNewGroupCall(GroupCall groupCall) async {}

  @override
  bool get isWeb => kIsWeb;

  @override
  Future<webrtc_impl.RTCPeerConnection> createPeerConnection(
      Map<String, dynamic> configuration,
      [Map<String, dynamic> constraints = const {}]) {
    return webrtc_impl.createPeerConnection(configuration, constraints);
  }

  @override
  webrtc_impl.VideoRenderer createRenderer() {
    return webrtc_impl.RTCVideoRenderer();
  }

  @override
  Future<void> handleNewCall(CallSession session) async {
    switch (session.direction) {
      case CallDirection.kIncoming:
        player.play(AssetSource('audio/incoming-call-ringtone.wav'));

        break;
      case CallDirection.kOutgoing:
        player.play(AssetSource('audio/outgoing-call-ringtone.wav'));

        break;
    }
  }

  @override
  MediaDevices get mediaDevices => webrtc_impl.navigator.mediaDevices;

  @override
  Future<void> playRingtone() async {
    // throw UnimplementedError();
  }

  @override
  Future<void> stopRingtone() async {
    await player.stop();
  }
}
