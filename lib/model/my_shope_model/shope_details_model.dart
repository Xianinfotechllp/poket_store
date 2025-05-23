class ShopeDetailsModel {
  final String id;
  final String shopName;
  final List<String> category;
  final String sellerType;
  final String state;
  final String? place;
  final String pinCode;
  final String headerImage;

  ShopeDetailsModel({
    required this.id,
    required this.shopName,
    required this.category,
    required this.sellerType,
    required this.state,
    this.place,
    required this.pinCode,
    required this.headerImage,
  });

  factory ShopeDetailsModel.fromJson(Map<String, dynamic> json) {
    return ShopeDetailsModel(
      id: json['_id'] ?? '',
      shopName: json['shopName'] ?? '',
      category: List<String>.from(json['category'] ?? []),
      sellerType: json['sellerType'] ?? '',
      state: json['state'] ?? '',
      // place: json['place'] ?? '',
      pinCode: json['pinCode'] ?? '',
      headerImage: json['headerImage'] ?? '',
    );
  }
}
