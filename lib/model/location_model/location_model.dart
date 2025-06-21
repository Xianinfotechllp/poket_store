class LocationMapModel {
  final String? latitude;
  final String? longitude;
  final String locality;
  final String state;
  final String pincode;
  final String place;

  LocationMapModel({
    this.latitude,
    this.longitude,
    required this.locality,
    required this.state,
    required this.pincode,
    required this.place,
  });
  factory LocationMapModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    return LocationMapModel(
      state: location['state'] ?? '',
      place: location['place'] ?? '',
      locality: location['locality'] ?? '',
      pincode: location['pincode'] ?? '',
      latitude: location['latitude'] ?? '',
      longitude: location['longitude'] ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'locality': locality,
    'state': state,
    'pincode': pincode,
    'place': place,
  };
}
