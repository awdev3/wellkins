import 'dart:convert';

import 'package:wellkins/utils/extensions.dart';

List<ContestDetails> contestDetailsFromJson(dynamic data) {
  final allContest = data["getAllContest"];
  return List<ContestDetails>.from(
      allContest.map((x) => ContestDetails.fromJson(x)));
}

class ContestDetails {
  int id;
  int status;
  bool isOver;
  List<String> clientJoined;

  ContestDetails({
    required this.id,
    required this.status,
    required this.isOver,
    required this.clientJoined,
  });

  factory ContestDetails.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    final endDt = DateTime.parse('${json['end_date']} ${json['end_time']}');
    //reciving in this 2024-05-26 19:35:00.000
    final isOver = now.isAfter(endDt) ? true : false;

    return ContestDetails(
      id: json["id"],
      status: '${json["status"]}'.toInt,
      isOver: isOver,
      clientJoined: json["client_joined"] != null
          ? List<String>.from(json["client_joined"].map((x) => '$x'))
          : [],
    );
  }
}

//
String joinContestToJson(JoinContest data) => json.encode(data.toJson());

class JoinContest {
  Draw draw;
  JoinContest({required this.draw});
  Map<String, dynamic> toJson() => {"draw": draw.toJson()};
}

class Draw {
  int id;
  String clientJoined;
  Draw({required this.id, required this.clientJoined});

  Map<String, dynamic> toJson() => {
        "id": id,
        "client_joined": [clientJoined],
        "isJoin": "Y",
      };
}

String voteToJson(Vote data) => json.encode(data.toJson());

class Vote {
  VoteItem vote;

  Vote({required this.vote});

  Map<String, dynamic> toJson() => {"vote": vote.toJson()};
}

class VoteItem {
  int propId;
  String userId;
  String clientName;
  String propName;
  int voteType;

  VoteItem({
    required this.propId,
    required this.userId,
    required this.clientName,
    required this.propName,
    required this.voteType,
  });

  Map<String, dynamic> toJson() => {
        "prop_id": propId,
        "user_id": userId,
        "client_name": clientName,
        "prop_name": propName,
        "vote": voteType,
      };
}

List<NewsAndInsights> newsAndInsightsFromJson(dynamic data) {
  final allNews = data["getAllBlog"]["rows"];
  return List<NewsAndInsights>.from(
      allNews.map((x) => NewsAndInsights.fromJson(x)));
}

class NewsAndInsights {
  String blogTitle;
  String blogDesc;
  String blogBody;

  NewsAndInsights({
    required this.blogTitle,
    required this.blogDesc,
    required this.blogBody,
  });

  factory NewsAndInsights.fromJson(Map<String, dynamic> json) =>
      NewsAndInsights(
        blogTitle: json["blog_title"],
        blogDesc: json["blog_desc"],
        blogBody: json["blog_body"],
      );
}

String propDetailToJson(PropDetail data) => json.encode(data.toJson());

class PropDetail {
  int propId;

  PropDetail({
    required this.propId,
  });

  Map<String, dynamic> toJson() => {"prop_id": propId};
}

String unitCertDetailToJson(UnitCertDetail data) => json.encode(data.toJson());

class UnitCertDetail {
  String orderId;
  String clientId;
  String propName;
  String fundSubType;

  UnitCertDetail({
    required this.orderId,
    required this.clientId,
    required this.propName,
    required this.fundSubType,
  });

  Map<String, dynamic> toJson() => {
        "orderId": orderId,
        "clientId": clientId,
        "propName": propName,
        "propType": fundSubType,
      };
}

String applcnDataToJson(ApplcnData data) => json.encode(data.toJson());
// String applcnDataToJson(ApplcnData data) {
//   final jsonString = json.encode(data.toJson());
//   // return utf8.fuse(base64).encode(jsonString);
//   // Encrypt the serialized data
//   const key = 'qw@1mklittgv98928hhaJY78&2hhgg12';
//   final encryptedText = CryptoDart.AES.encrypt(jsonString, key);
//   // Encode the encrypted data to Base64
//   // String encodedData = base64UrlEncode(encryptedText);
//   return encryptedText.toString();
// }

class ApplcnData {
  final int id;
  final int clientType;
  final String token;
  final String email;
  final String name;
  final String contact;
  final int type;
  final String img;
  final int clientId;
  final int propId;
  final String propName;
  final int fundSubType;

  ApplcnData({
    required this.id,
    required this.clientType,
    required this.token,
    required this.email,
    required this.name,
    required this.contact,
    required this.type,
    required this.img,
    required this.clientId,
    required this.propId,
    required this.propName,
    required this.fundSubType,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "client_type": clientType,
        "token": token,
        "email": email,
        "name": name,
        "contact": contact,
        "type": type,
        "img": img,
        "cid": clientId,
        "prop_id": propId,
        "prop_name": propName,
        "prop_type": fundSubType
      };
}

// final userReceipts = userReceiptsFromJson(jsonString);
List<UserReceipt> userReceiptsFromJson(dynamic data) {
  final userReceipts = data["receipt"];
  return List<UserReceipt>.from(
      userReceipts.map((x) => UserReceipt.fromJson(x)));
}

class UserReceipt {
  final int id;
  final String fileName;
  final String fileType;
  final String url;
  final String userComment;
  // final int clientId;
  // final String orderId;
  // final dynamic adminComment;
  // final DateTime createdAt;
  // final DateTime updatedAt;

  UserReceipt({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.url,
    required this.userComment,
    //  required this.clientId,
    // required this.orderId,
    // required this.adminComment,
    // required this.createdAt,
    // required this.updatedAt,
  });

  factory UserReceipt.fromJson(Map<String, dynamic> json) {
    final url = json["url"] ?? '';
    final uri = Uri.parse(url);
    final filename = uri.fileName;
    final fileType = uri.fileType;
    return UserReceipt(
      id: json["id"],
      fileName: filename,
      fileType: fileType,
      url: url,
      userComment: json["user_comment"],
      //  clientId: json["client_id"],
      // orderId: json["order_id"],
      // adminComment: json["admin_comment"],
      // createdAt: DateTime.parse(json["createdAt"]),
      // updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}

String receiptIdToJson(ReceiptId data) => json.encode(data.toJson());

class ReceiptId {
  final String orderId;

  ReceiptId({required this.orderId});

  Map<String, dynamic> toJson() => {"order_id": orderId};
}
