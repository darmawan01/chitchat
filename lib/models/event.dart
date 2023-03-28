class EventContent {
  String? msgtype;
  String? body;
  List<String>? userIds;

  EventContent({this.msgtype, this.body});

  EventContent.fromJson(Map<String, dynamic> json) {
    msgtype = json['msgtype'];
    body = json['body'];
    userIds = List.from(json['user_ids'] ?? []);
  }

  String get cleanedUserIds {
    return userIds?.map((e) => e.split(":")[0]).join(",") ?? "";
  }
}
