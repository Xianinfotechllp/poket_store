class LocationModel {
  final String state;
  final String place;
  final String locality;
  final String pincode;

  LocationModel({
    required this.state,
    required this.place,
    required this.locality,
    required this.pincode,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      state: json['state'] ?? '',
      place: json['place'] ?? '',
      locality: json['locality'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'place': place,
      'locality': locality,
      'pincode': pincode,
    };
  }
}
