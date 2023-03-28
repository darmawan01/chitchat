enum QuickCallSignal {
  emergency,
  help,
  accepted,
  canceled,
  rejected;

  @override
  String toString() {
    switch (this) {
      case QuickCallSignal.emergency:
        return '567a37e1-1883-4e79-b2c4-9c66a812cae5';
      case QuickCallSignal.help:
        return '74507cd7-da24-40c6-9624-1891330aff88';
      case QuickCallSignal.accepted:
        return 'c04fa10d-a93d-4d80-9d8e-31cfcc5d8532';
      case QuickCallSignal.rejected:
        return 'bb48dfe8-5ce1-4496-9f49-b70996b3e6d4';
      case QuickCallSignal.canceled:
        return '2beabed3-97f0-4a65-94ac-a9f7c3ad0e61';
    }
  }
}

class QuickCall {
  QuickCallSignal? signal;

  QuickCall({required this.signal});

  QuickCall.fromJson(Map<String, dynamic> json) {
    if (json["signal"] == QuickCallSignal.emergency.toString()) {
      signal = QuickCallSignal.emergency;
    } else if (json["signal"] == QuickCallSignal.help.toString()) {
      signal = QuickCallSignal.help;
    } else if (json["signal"] == QuickCallSignal.accepted.toString()) {
      signal = QuickCallSignal.accepted;
    } else if (json["signal"] == QuickCallSignal.rejected.toString()) {
      signal = QuickCallSignal.rejected;
    } else if (json["signal"] == QuickCallSignal.canceled.toString()) {
      signal = QuickCallSignal.canceled;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "signal": signal.toString(),
    };
  }

  bool get isEmergencyCall => signal == QuickCallSignal.emergency;
  bool get isHelpCall => signal == QuickCallSignal.help;
  bool get isCallAccepted => signal == QuickCallSignal.accepted;
  bool get isCallRejected => signal == QuickCallSignal.rejected;
  bool get isCallCanceled => signal == QuickCallSignal.canceled;

  String toMessage(String sender) {
    switch (signal) {
      case QuickCallSignal.emergency:
        return "Emergency call from $sender";
      case QuickCallSignal.help:
        return "$sender Need help";
      case QuickCallSignal.rejected:
        return "$sender Rejected the call";
      case QuickCallSignal.accepted:
        return "$sender Accepted the call";
      case QuickCallSignal.canceled:
        return "$sender Canceled the call";
      default:
        return "";
    }
  }
}
