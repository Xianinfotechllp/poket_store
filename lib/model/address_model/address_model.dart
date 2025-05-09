class AddressModel {
  final String countryName;
  final String phoneNumber;
  final String houseNo;
  final String area;
  final String landmark;
  final String pincode;
  final String town;
  final String state;
  final String? id;

  AddressModel({
    required this.countryName,
    required this.phoneNumber,
    required this.houseNo,
    required this.area,
    required this.landmark,
    required this.pincode,
    required this.town,
    required this.state,
    this.id,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      countryName: json['countryName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      houseNo: json['houseNo'] ?? '',
      area: json['area'] ?? '',
      landmark: json['landmark'] ?? '',
      pincode: json['pincode'] ?? '',
      town: json['town'] ?? '',
      state: json['state'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "countryName": countryName,
      "phoneNumber": phoneNumber,
      "houseNo": houseNo,
      "area": area,
      "landmark": landmark,
      "pincode": pincode,
      "town": town,
      "state": state,
    };
  }
}
