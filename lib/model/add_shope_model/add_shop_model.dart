class ShopModel {
  final String? id;
  final String shopName;
  final List<String> category;
  final String sellerType;
  final String state;
  final String place;
  final String pinCode;
  final String headerImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ShopModel({
    this.id,
    required this.shopName,
    required this.category,
    required this.sellerType,
    required this.state,
    required this.place,
    required this.pinCode,
    required this.headerImage,
    this.createdAt,
    this.updatedAt,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json["_id"],
      shopName: json["shopName"],
      category:
          (json['category'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      sellerType: json["sellerType"],
      state: json["state"],
      place: json["place"],
      pinCode: json["pinCode"],
      headerImage: json["headerImage"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "shopName": shopName,
      "category": category,
      "sellerType": sellerType,
      "state": state,
      "place": place,
      "pinCode": pinCode,
      "headerImage": headerImage,
    };
  }
}
