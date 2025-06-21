// To parse this JSON data, do
//
//     final notificationList = notificationListFromJson(jsonString);

import 'dart:convert';

List<NotificationModel> notificationListFromJson(String str) =>
    List<NotificationModel>.from(
      json.decode(str).map((x) => NotificationModel.fromJson(x)),
    );

String notificationListToJson(List<NotificationModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final Data data;
  final DateTime createdAt;
  final Recipient recipient;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.createdAt,
    required this.recipient,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["_id"],
        title: json["title"],
        body: json["body"],
        type: json["type"],
        data: Data.fromJson(json["data"]),
        createdAt: DateTime.parse(json["createdAt"]),
        recipient: Recipient.fromJson(json["recipient"]),
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "body": body,
    "type": type,
    "data": data.toJson(),
    "createdAt": createdAt.toIso8601String(),
    "recipient": recipient.toJson(),
  };

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    Data? data,
    DateTime? createdAt,
    Recipient? recipient,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      recipient: recipient ?? this.recipient,
    );
  }
}

class Data {
  final String? shopId;
  final String? shopName;
  final String? productId;
  final String? productName;

  Data({this.shopId, this.shopName, this.productId, this.productName});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    shopId: json["shopId"],
    shopName: json["shopName"],
    productId: json["productId"],
    productName: json["productName"],
  );

  Map<String, dynamic> toJson() => {
    "shopId": shopId,
    "shopName": shopName,
    "productId": productId,
    "productName": productName,
  };

  Data copyWith({
    String? shopId,
    String? shopName,
    String? productId,
    String? productName,
  }) {
    return Data(
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
    );
  }
}

class Recipient {
  final String userId;
  final bool isRead;

  Recipient({required this.userId, required this.isRead});

  factory Recipient.fromJson(Map<String, dynamic> json) =>
      Recipient(userId: json["userId"], isRead: json["isRead"]);

  Map<String, dynamic> toJson() => {"userId": userId, "isRead": isRead};

  Recipient copyWith({String? userId, bool? isRead}) {
    return Recipient(
      userId: userId ?? this.userId,
      isRead: isRead ?? this.isRead,
    );
  }
}
