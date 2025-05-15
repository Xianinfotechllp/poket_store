import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/order_model/order_model.dart';
import 'package:poketstore/service/order_service/order_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  List<Order> orders = [];
  Order? selectedOrder; // Store single order details separately
  bool isLoading = false;

  /// **Fetch User Orders Using Saved Token & User ID**
  Future<void> fetchUserOrders() async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      String? token = prefs.getString('token');

      log("Retrieved userId: $userId");
      log("Retrieved token: $token");

      if (userId == null || token == null) {
        throw Exception("User not logged in or missing credentials.");
      }

      orders = await _orderService.fetchOrders(userId, token);
    } catch (e) {
      log("Error fetching user orders: $e");
      orders = []; // Ensure orders list is reset on failure
    }

    isLoading = false;
    notifyListeners();
  }

  /// **Fetch Order Details Using Order ID**
  Future<void> fetchOrderDetails(String orderId) async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      log("Retrieved token: $token");

      if (token == null) {
        throw Exception("User not logged in or missing token.");
      }

      selectedOrder = await _orderService.fetchOrderDetails(orderId, token);
    } catch (e) {
      log("Error fetching order details controller: $e");
      selectedOrder = null;
    }

    isLoading = false;
    notifyListeners();
  }
}
