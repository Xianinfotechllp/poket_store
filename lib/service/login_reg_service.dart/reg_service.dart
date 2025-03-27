import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/login_reg_model/reg_model.dart';

class RegistrationService {
  final Dio _dio = Dio();
  final String _registerUrl =
      "https://shop-app-be.onrender.com/auth/user/register";

  Future<RegistrationModel> registerUser(Map<String, dynamic> data) async {
    try {
      Response response = await _dio.post(
        _registerUrl,
        data: jsonEncode(data),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      log("Registration Response: ${response.data}");

      return RegistrationModel.fromJson(response.data);
    } catch (e) {
      log("Registration Error: $e");
      throw Exception("Registration failed");
    }
  }
}
