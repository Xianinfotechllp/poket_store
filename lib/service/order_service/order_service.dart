import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poketstore/model/order_model/order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: 'https://shop-app-backend-gsx6.onrender.com/api/'),
  );

  Future<OrderResponse?> placeOrder(PlaceOrderRequest request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(
        'token',
      ); // Make sure token is saved in SharedPreferences

      final response = await _dio.post(
        'order/place',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      log('Place Order Response: ${response.data}');
      return OrderResponse.fromJson(response.data);
    } catch (e) {
      log('Place order failed: $e');
      return null;
    }
  }
}
