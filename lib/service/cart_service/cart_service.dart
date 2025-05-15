import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/cart_model/cart_model.dart';

class CartService {
  final Dio _dio = Dio();
  final String _baseUrl = "https://shop-by-sabu-q.onrender.com/api/cart";

  Future<Cart> addToCart(List<CartItem> items, String token) async {
    try {
      log("🔹 Sending request to update cart: ${items.map((e) => e.toJson())}");
      log("Token being sent: $token");
      final response = await _dio.post(
        _baseUrl,
        data: {"items": items.map((e) => e.toJson()).toList()},
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        log("✅ Cart updated successfully: ${response.data}");
        return Cart.fromJson(response.data['cart']);
      } else {
        throw Exception(
          "Failed to update cart. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      log("❌ Error updating cart: $e");
      throw Exception("Failed to update cart");
    }
  }

  Future<Cart> fetchCart(String token) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/user',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        log('Cart fetched successfully: ${response.data}');
        return Cart.fromJson(response.data['cart']);
      } else {
        throw Exception('Failed to fetch cart. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      log(
        'Dio Error fetching cart: ${e.response?.statusCode} - ${e.response?.data}',
      );
      throw Exception('Failed to fetch cart');
    } catch (e) {
      log('Error fetching cart: $e');
      throw Exception('Failed to fetch cart');
    }
  }

  Future<Cart> updateCart(List<CartItem> items, String token) async {
    try {
      final response = await _dio.post(
        '$_baseUrl',
        data: {"items": items.map((e) => e.toJson()).toList()},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        log('Cart updated successfully: ${response.data}');
        return Cart.fromJson(response.data['cart']);
      } else {
        throw Exception(
          'Failed to update cart. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      log(
        'Dio error updating cart: ${e.response?.statusCode} - ${e.response?.data}',
      );
      throw Exception('Failed to update cart');
    } catch (e) {
      log('Error updating cart: $e');
      throw Exception('Failed to update cart');
    }
  }
}
