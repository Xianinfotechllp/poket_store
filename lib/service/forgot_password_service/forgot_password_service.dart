// service/forgot_password_service.dart
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/forgot_password_model/forgot_password_model.dart'; // Make sure this path is correct

class ForgotPasswordService {
  final Dio _dio = Dio();
  static const String _baseUrl =
      "https://shop-app-backend-gsx6.onrender.com/auth/user";

  Future<ApiResponse> sendOtp(SendOtpRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/send-otp',
        data: request.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      log('Send OTP Response: ${response.data}');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      log('Send OTP Dio Error: ${e.response?.data ?? e.message}');
      throw Exception(
        e.response?.data['message'] ?? 'Failed to send OTP. Please try again.',
      );
    } catch (e) {
      log('Send OTP Generic Error: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<ApiResponse> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/verify-otp',
        data: request.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      log('Verify OTP Response: ${response.data}');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      log('Verify OTP Dio Error: ${e.response?.data ?? e.message}');
      throw Exception(
        e.response?.data['message'] ??
            'Failed to verify OTP. Please try again.',
      );
    } catch (e) {
      log('Verify OTP Generic Error: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<ApiResponse> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/reset-password',
        data: request.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      log('Reset Password Response: ${response.data}');
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      log('Reset Password Dio Error: ${e.response?.data ?? e.message}');
      throw Exception(
        e.response?.data['message'] ??
            'Failed to reset password. Please try again.',
      );
    } catch (e) {
      log('Reset Password Generic Error: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }
}
