import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/order_model/order_model.dart';

class OrderService {
  final Dio _dio = Dio();
  final String baseUrl =
      "https://shop-app-backend-main.onrender.com/api/order/user";

  Future<List<Order>> fetchOrders(String userId, String token) async {
    try {
      final response = await _dio.get(
        "$baseUrl/$userId",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 && response.data['orders'] != null) {
        List<dynamic> ordersJson = response.data['orders'];
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch orders");
      }
    } catch (e) {
      log("Error fetching orders: $e");
      return [];
    }
  }

  Future<Order?> fetchOrderDetails(String orderId, String token) async {
    try {
      final response = await _dio.get(
        "https://shop-app-backend-main.onrender.com/api/order/get-order/$orderId",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data.containsKey("order")) {
          return Order.fromJson(data["order"]); // Extract 'order' before parsing
        } else {
          throw Exception("Order data not found in response");
        }
      } else {
        throw Exception("Failed to fetch order details");
      }
    } catch (e) {
      log("Error fetching order details service: $e");
      return null;
    }
  }

}
