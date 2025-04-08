import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/shop_of_user_model/shop_of_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopOfUserService {
  final Dio _dio = Dio();

  Future<List<ShopOfUser>> getShopsByUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');

    if (userId == null || token == null) {
      throw Exception("User ID or token not found");
    }

    try {
      final response = await _dio.get(
        "https://shop-by-sabu-q.onrender.com/api/shops/by-user",
        queryParameters: {"userId": userId},
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      final data = response.data['data'] as List;
      return data.map((e) => ShopOfUser.fromJson(e)).toList();
    } catch (e) {
      log("ShopOfUserService Error: $e");
      rethrow;
    }
  }
}
