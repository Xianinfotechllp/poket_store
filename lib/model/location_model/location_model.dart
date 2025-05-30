class LocationMapModel {
  final String state;
  final String place;
  final String locality;
  final String pincode;

  LocationMapModel({
    required this.state,
    required this.place,
    required this.locality,
    required this.pincode,
  });

  factory LocationMapModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    return LocationMapModel(
      state: location['state'] ?? '',
      place: location['place'] ?? '',
      locality: location['locality'] ?? '',
      pincode: location['pincode'] ?? '',
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
