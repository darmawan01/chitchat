import 'package:matrix/matrix.dart';

class EventsTypes {
  static const String Typing = "m.typing";
}

class Events {
  String? type;
  Content? content;
  String? sender;
  String? eventId;
  int? originServerTs;
  int? status;

  Events({
    this.type,
    this.content,
    this.sender,
    this.eventId,
    this.originServerTs,
    this.status,
  });

  Events.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    content =
        json['content'] != null ? Content.fromJson(json['content']) : null;
    sender = json['sender'];
    eventId = json['event_id'];
    originServerTs = json['origin_server_ts'];
    status = json['status'];
  }

  get isEventMessage => type == EventTypes.Message;

  get isTypingEvent => type == EventsTypes.Typing;
}

class Content {
  String? msgtype;
  String? body;
  List<String>? userIds;

  Content({this.msgtype, this.body});

  Content.fromJson(Map<String, dynamic> json) {
    msgtype = json['msgtype'];
    body = json['body'];
    userIds = List.from(json['user_ids'] ?? []);
  }

  String get cleanedUserIds {
    return userIds?.map((e) => e.split(":")[0]).join(",") ?? "";
  }
}
