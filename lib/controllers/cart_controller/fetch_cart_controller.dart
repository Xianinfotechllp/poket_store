// lib/controllers/cart_controller/cart_controller.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/cart_model/cart_model.dart';
import 'package:poketstore/model/cart_model/fetch_cart_model.dart';
import 'package:poketstore/service/cart_service/cart_service.dart'; // Corrected import
import 'package:poketstore/service/cart_service/fetch_cart_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FetchCartController extends ChangeNotifier {
  final FetchCartService _service =
      FetchCartService(); // Using the renamed service
  CartModel? _cart;
  bool _isLoading = false;

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;

  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    final result = await _service.getCart(token);
    if (result != null) {
      _cart = result.cart;
    } else {
      _cart = null; // Set cart to null if fetching fails
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      log("No token found to update quantity.");
      return;
    }

    // Optionally, show a local loading indicator or disable buttons
    // Notifying listeners here would rebuild the whole cart, so it's
    // better to handle specific item updates or a global overlay.
    // For simplicity, we'll just refetch the cart after the update.

    final success = await _service.updateCartItemQuantity(
      token,
      productId,
      newQuantity,
    );

    if (success) {
      log("Quantity update successful, refetching cart...");
      // Re-fetch the entire cart to update the UI
      await fetchCart();
    } else {
      log("Failed to update quantity.");
      // Handle error, e.g., show a SnackBar
    }
  }

  Future<void> removeItemFromCart(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      log("No token found to remove item.");
      return;
    }

    // Optionally show a loading indicator or confirmation dialog
    log("Attempting to remove product $productId from cart...");
    final success = await _service.removeCartItem(token, productId);

    if (success) {
      log("Item removal successful, refetching cart...");
      // Re-fetch the cart to update the UI
      await fetchCart();
    } else {
      log("Failed to remove item from cart.");
      // Handle error, e.g., show a SnackBar
    }
  }
}
