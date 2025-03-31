import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/cart_model/cart_model.dart';
import 'package:poketstore/service/cart_service/cart_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();
  Cart? cart;

  Future<void> addCart(List<CartItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        log("⚠️ No valid token found. Redirecting to login...");
        return;
      }

      log("🔹 Token found, proceeding with cart update.$token");

      cart = await _cartService.addToCart(items, token);

      notifyListeners();
    } catch (e) {
      log("❌ Error Adding cart controller: $e");
    }
  }

  bool isLoading = false;
  Future<void> fetchCart() async {
    isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      log('Fetching cart with token: $token'); // Log the token

      if (token == null || token.isEmpty) {
        log('No valid token found.');
        isLoading = false;
        notifyListeners();
        return;
      }

      cart = await _cartService.fetchCart(token);

      log(
        'Cart fetched successfully: ${cart?.items.length} items',
      ); // Log cart data
    } catch (e) {
      log('Error fetching cart: $e');
      cart = null; // Ensure cart is null on error
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateCart(List<CartItem> items) async {
    isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        log('No valid token found.');
        isLoading = false;
        notifyListeners();
        return;
      }

      cart = await _cartService.updateCart(items, token);
    } catch (e) {
      log('Error updating cart: $e');
      cart = null;
    }
    isLoading = false;
    notifyListeners();
  }
}
