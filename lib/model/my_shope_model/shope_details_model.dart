class ShopeDetailsModel {
  final String? id;
  final String? shopName;
  final List<String>? category;
  final String? sellerType;
  final String? state;
  final String? place;
  final String? pinCode;
  final String? locality;
  final String? headerImage;
  final String? email; // New field
  final String? mobileNumber; // New field
  final String? landlineNumber; // New field

  ShopeDetailsModel({
    this.id,
    this.shopName,
    this.category,
    this.sellerType,
    this.state,
    this.place,
    this.pinCode,
    this.locality,
    this.headerImage,
    this.email, // Initialize new field
    this.mobileNumber, // Initialize new field
    this.landlineNumber, // Initialize new field
  });

  factory ShopeDetailsModel.fromJson(Map<String, dynamic> json) {
    return ShopeDetailsModel(
      id: json['_id'] as String?,
      shopName: json['shopName'] as String?,
      category: (json['category'] as List?)?.map((e) => e.toString()).toList(),
      sellerType: json['sellerType'] as String?,
      state: json['state'] as String?,
      place: json['place'] as String?,
      pinCode: json['pinCode'] as String?,
      locality: json['locality'] as String?,
      headerImage: json['headerImage'] as String?,
      email: json['email'] as String?, // Parse new field
      mobileNumber: json['mobileNumber'] as String?, // Parse new field
      landlineNumber: json['landlineNumber'] as String?, // Parse new field
    );
  }
}
