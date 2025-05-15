class UserProfile {
  final String id;
  final String name;
  final int mobileNumber;
  final String password;
  final String state;

  UserProfile({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.password,
    required this.state,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      mobileNumber: json['mobileNumber'] ?? 0,
      password: json['password'] ?? '',
      state: json['state'] ?? '',
    );
  }
}
