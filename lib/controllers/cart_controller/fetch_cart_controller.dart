import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poketstore/model/cart_model/fetch_cart_model.dart';
import 'package:poketstore/service/cart_service/fetch_cart_service.dart';
import 'dart:developer';

class FetchCartProvider with ChangeNotifier {
  bool isLoading = false;
  String errorMessage = '';
  FetchCartModel? cartData;

  Future<void> fetchCart() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();
    log("🛒 Fetching cart...");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      log("🔑 Retrieved token: $token");

      if (token == null) {
        errorMessage = 'User not logged in';
        isLoading = false;
        notifyListeners();
        log("⚠️ Error: User not logged in");
        return;
      }

      final service = FetchCartService();
      final response = await service.fetchCart(token);
      log("Response from fetchCart service: $response");

      if (response != null) {
        cartData = response;
        log(
          "✅ Cart data fetched successfully: ${cartData?.cart.items.length} items, ",
        );
      } else {
        errorMessage = 'Failed to fetch cart';
        log("❌ Error: Failed to fetch cart");
      }
    } catch (e) {
      errorMessage = 'An error occurred: $e';
      log("🔥 Error during cart fetch: $e");
    }

    isLoading = false;
    notifyListeners();
    log(
      "🔄 Cart fetch completed. Loading: $isLoading, Error: '$errorMessage', Data: $cartData",
    );
  }
}
