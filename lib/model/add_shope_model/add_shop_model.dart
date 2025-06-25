class ShopModel {
  final String? id;
  final String? userId;
  final String? shopName;
  final List<String>? category;
  final String? sellerType;
  final String? state;
  final String? place;
  final String? pinCode;
  final String? locality;
  final String? headerImage; // Changed to nullable
  final String? email;
  final String? mobileNumber;
  final String? landlineNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ShopModel({
    this.userId,
    this.id,
    this.locality,
    this.shopName,
    this.category,
    this.sellerType,
    this.state,
    this.place,
    this.pinCode,
    this.headerImage, // No longer required
    this.email,
    this.mobileNumber,
    this.landlineNumber,
    this.createdAt,
    this.updatedAt,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json["_id"],
      locality: json["locality"], // It's already nullable, so no need for ?? ""
      userId: json['userId'], // It's already nullable, so no need for ?? ""
      shopName: json["shopName"] ?? "",
      category:
          json['category'] == null
              ? []
              : (json['category'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [],
      sellerType: json["sellerType"] ?? "",
      state: json["state"] ?? "",
      place: json["place"], // It's already nullable, so no need for ?? ""
      pinCode: json["pinCode"] ?? "",
      headerImage:
          json["headerImage"], // Directly assign, let it be null if not present
      email: json["email"], // Directly assign, let it be null if not present
      mobileNumber:
          json["mobileNumber"], // Directly assign, let it be null if not present
      landlineNumber:
          json["landlineNumber"], // Directly assign, let it be null if not present
      createdAt:
          json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
      updatedAt:
          json["updatedAt"] != null ? DateTime.parse(json["updatedAt"]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      "shopName": shopName,
      "category": category,
      "sellerType": sellerType,
      "state": state,
      "place": place,
      "pinCode": pinCode,
      "locality": locality,
      "headerImage": headerImage,
      "email": email,
      "mobileNumber": mobileNumber,
      "landlineNumber": landlineNumber,
    };
  }
}
