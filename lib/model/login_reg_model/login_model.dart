class LoginModel {
  final String message;
  final String token;
  final UserModel user;

  LoginModel({required this.message, required this.token, required this.user});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      message: json['message'],
      token: json['token'],
      user: UserModel.fromJson(json['user']),
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String mobileNumber;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      mobileNumber: json['mobileNumber'].toString(),
      role: json['role'],
    );
  }
}
