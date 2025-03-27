class RegistrationModel {
  final String id;
  final String name;
  final String mobileNumber;
  final String state;
  final String place;
  final String pincode;
  final String token;

  RegistrationModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.state,
    required this.place,
    required this.pincode,
    required this.token,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      id: json['user']['id'],
      name: json['user']['name'],
      mobileNumber: json['user']['mobileNumber'],
      state: json['user']['state'],
      place: json['user']['place'],
      pincode: json['user']['pincode'],
      token: json['token'],
    );
  }
}
