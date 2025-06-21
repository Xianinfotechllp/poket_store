// model/forgot_password_model.dart

class SendOtpRequest {
  final String email;

  SendOtpRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class VerifyOtpRequest {
  final String email;
  final String otp;

  VerifyOtpRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp};
  }
}

class ResetPasswordRequest {
  final String email;
  final String otp;
  final String newPassword;

  ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp, 'newPassword': newPassword};
  }
}

// For simpler responses, a generic success model is often enough
class ApiResponse {
  final String message;

  ApiResponse({required this.message});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(message: json['message'] as String);
  }
}
