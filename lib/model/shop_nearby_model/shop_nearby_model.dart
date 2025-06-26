class ShopNearbyModel {
  final String? id;
  final String? owner;
  final String? shopName;
  final List<String>? category;
  final String? sellerType;
  final String? state;
  final String? place;
  final String? locality;
  final String? pinCode;
  final String? headerImage;
  final String? email;
  final String? mobileNumber;

  ShopNearbyModel({
    this.id,
    this.owner,
    this.shopName,
    this.category,
    this.sellerType,
    this.state,
    this.place,
    this.locality,
    this.pinCode,
    this.headerImage,
    this.email,
    this.mobileNumber,
  });

  factory ShopNearbyModel.fromJson(Map<String, dynamic> json) {
    return ShopNearbyModel(
      id: json['_id'] as String?,
      owner: json['owner'] as String?,
      shopName: json['shopName'] as String?,
      category:
          (json['category'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList(),
      sellerType: json['sellerType'] as String?,
      state: json['state'] as String?,
      place: json['place'] as String?,
      locality: json['locality'] as String?,
      pinCode: json['pinCode'] as String?,
      headerImage: json['headerImage'] as String?,
      email: json['email'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
    );
  }
}
