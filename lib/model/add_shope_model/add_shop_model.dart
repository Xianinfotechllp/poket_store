class ShopModel {
  final String? id;
  final String? userId;
  final String shopName;
  final List<String> category;
  final String sellerType;
  final String state;
  // final String place;
  final String pinCode;
  // final String locality;
  final String headerImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ShopModel({
    this.userId,
    this.id,
    // required this.locality,
    required this.shopName,
    required this.category,
    required this.sellerType,
    required this.state,
    // required this.place,
    required this.pinCode,
    required this.headerImage,
    this.createdAt,
    this.updatedAt,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json["_id"],
      // locality: json["locality"] ?? "",
      userId: json['userId'] ?? "",
      shopName: json["shopName"] ?? "",
      category: json['category'] == null
          ? []
          : (json['category'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
      sellerType: json["sellerType"] ?? "",
      state: json["state"] ?? "",
      // place: json["place"] ??"",
      pinCode: json["pinCode"] ?? "",
      headerImage: json["headerImage"] ?? "",
      createdAt:
          DateTime.parse(json["createdAt"] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json["updatedAt"] ?? DateTime.now().toIso8601String()),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      "shopName": shopName,
      "category": category,
      "sellerType": sellerType,
      "state": state,
      // "place": place,
      "pinCode": pinCode,
      // "locality": locality,
      "headerImage": headerImage,
    };
  }
}
