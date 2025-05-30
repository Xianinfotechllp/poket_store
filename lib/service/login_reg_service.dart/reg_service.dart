import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/login_reg_model/reg_model.dart';

class RegistrationService {
  final Dio _dio = Dio();
  final String _registerUrl =
      "https://shop-app-backend-gsx6.onrender.com/auth/user/register";

  Future<RegistrationModel> registerUser(Map<String, dynamic> data) async {
    try {
      Response response = await _dio.post(
        _registerUrl,
        data: jsonEncode(data),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      log("Registration Response: ${response.data}");

      // Check if response.data is a Map before accessing it.
      if (response.data is Map<String, dynamic>) {
        return RegistrationModel.fromJson(response.data);
      } else {
        // Handle the case where response.data is not a Map.  Maybe it is a String?
        log("Error: response.data is not a Map.  It is of type ${response.data.runtimeType.toString()} and value ${response.data.toString()}");
        throw Exception(
            "Unexpected response format: ${response.data.toString()}");
      }
    } catch (e) {
      log("Registration Error: $e");
      throw Exception("Registration failed");
    }
  }
}
