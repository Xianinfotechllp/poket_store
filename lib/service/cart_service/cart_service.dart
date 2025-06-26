import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/cart_model/cart_model.dart';

class CartService {
  final Dio _dio = Dio();

  Future<bool> addToCart(CartRequestModel request, String token) async {
    const url = 'https://shop-app-backend-gsx6.onrender.com/api/cart/add';

    try {
      log("Sending payload: ${request.toJson()}");
      final response = await _dio.post(
        url,
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      log("Add to cart response: ${response.data}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log("Add to cart error: $e");
      return false;
    }
  }
}
