class ShopNearbyModel {
  final String id;
  final String owner;
  final String shopName;
  final List<String> category;
  final String sellerType;
  final String state;
  final String place;
  final String locality;
  final String pinCode;
  final String? headerImage;
  final String? email;
  final String? mobileNumber;

  ShopNearbyModel({
    required this.id,
    required this.owner,
    required this.shopName,
    required this.category,
    required this.sellerType,
    required this.state,
    required this.place,
    required this.locality,
    required this.pinCode,
    this.headerImage,
    this.email,
    this.mobileNumber,
  });

  factory ShopNearbyModel.fromJson(Map<String, dynamic> json) {
    return ShopNearbyModel(
      id: json['_id'],
      owner: json['owner'],
      shopName: json['shopName'],
      category: List<String>.from(json['category']),
      sellerType: json['sellerType'],
      state: json['state'],
      place: json['place'],
      locality: json['locality'],
      pinCode: json['pinCode'],
      headerImage: json['headerImage'],
      email: json['email'],
      mobileNumber: json['mobileNumber'],
    );
  }
}
