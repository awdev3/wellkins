import 'dart:convert';

import '../utils/formatter.dart';

List<Noti> notiFromJson(dynamic data, int userId) =>
    List<Noti>.from(data.map((x) => Noti.fromJson(x, userId)));

class Noti {
  final String id;
  final String date;
  final String title;
  final String body;
  final String image;
  bool isRead;
  final List<int> notificationSeen;
  // final String route;
  // final String deepId;
  // final String categoryTitle;

  Noti({
    required this.id,
    required this.date,
    required this.title,
    required this.body,
    required this.isRead,
    required this.notificationSeen,
    this.image = '',
    // required this.route,
    // required this.deepId,
    // required this.categoryTitle,
  });

  factory Noti.fromJson(Map<String, dynamic> json, int userId) {
    final notiSeen = json["notification_seen"] == null
        ? <int>[]
        : List<int>.from(json["notification_seen"].map((x) => x));
    final isRead = notiSeen.contains(userId);
    return Noti(
      id: '${json["id"]}',
      date: Frmtr.frmtDate(
        date: '${json["notificationdate"]}',
        inForm: 'yyyy-MM-dd',
        outForm: 'dd/MM/yyyy',
      ),
      title: json["title"] ?? '',
      body: json["description"] ?? '',
      image: json["image"] ?? '',
      isRead: isRead,
      notificationSeen: notiSeen,
      // route: json["route"] ?? '',
      // deepId: json["deepId"] ?? '',
      // categoryTitle: json["categoryTitle"] ?? '',
    );
  }
}

String tokenDetailToJson(TokenDetail data) => json.encode(data.toJson());

class TokenDetail {
  String clientId;
  String userToken;

  TokenDetail({
    required this.clientId,
    required this.userToken,
  });

  Map<String, dynamic> toJson() => {
        "client_id": clientId,
        "user_token": userToken,
      };
}

String notiToJson(NotiClientDetail data) => json.encode(data.toJson());

class NotiClientDetail {
  int clientId;

  NotiClientDetail({required this.clientId});

  Map<String, dynamic> toJson() => {
        "client_id": [clientId]
      };
}

String resetCountToJson(List<ResetCount> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ResetCount {
  final int id;
  final List<int> isSeen;

  ResetCount({
    required this.id,
    required this.isSeen,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "isSeen": List<dynamic>.from(isSeen.map((x) => x)),
      };
}
