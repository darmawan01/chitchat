import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc_impl;
import 'package:matrix/matrix.dart';
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:webrtc_interface/src/mediadevices.dart';

class VoipService implements WebRTCDelegate {
  final player = AudioPlayer();

  @override
  void handleCallEnded(CallSession session) {
    // handle call ended by local or remote
  }

  @override
  bool get canHandleNewCall => true;

  @override
  void handleGroupCallEnded(GroupCall groupCall) {
    // TODO: implement handleGroupCallEnded
  }

  @override
  void handleMissedCall(CallSession session) {
    // TODO: implement handleMissedCall
  }

  @override
  void handleNewGroupCall(GroupCall groupCall) {
    // TODO: implement handleNewGroupCall
  }

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
  void handleNewCall(CallSession session) {
    switch (session.direction) {
      case CallDirection.kIncoming:
        player.play(AssetSource("audio/incoming-call-ringtone.wav"));
        break;
      case CallDirection.kOutgoing:
        player.play(AssetSource("audio/outgoing-call-ringtone.wav"));
        break;
    }
  }

  @override
  MediaDevices get mediaDevices => webrtc_impl.navigator.mediaDevices;

  @override
  void playRingtone() {}

  @override
  void stopRingtone() {
    player.stop();
  }
}
