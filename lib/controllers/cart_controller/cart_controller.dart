import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poketstore/model/cart_model/cart_model.dart';
import 'package:poketstore/service/cart_service/cart_service.dart';

// Assuming you have a model for a cart item that includes productId and quantity
// For example:
// class CartItem {
//   final String productId;
//   final int quantity;
//   CartItem({required this.productId, required this.quantity});
// }

class CartController extends ChangeNotifier {
  final CartService _cartService = CartService();
  bool _isAdding = false;
  bool get isAdding => _isAdding;

  // Add a list to hold current cart items (you'll need to fetch this from your backend)
  List<String> _cartProductIds = []; // Stores just product IDs for quick checks
  List<String> get cartProductIds => _cartProductIds;

  CartController() {
    // Optionally, fetch cart items when the controller is initialized
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    // Implement logic to fetch actual cart items from your backend
    // For now, let's simulate it or assume it's done elsewhere
    // This is a placeholder. You'll likely have a service call here
    _cartProductIds = []; // Clear existing for refresh
    log("Fetching cart items (simulated)...");
    // Example: Replace with actual API call to get user's cart
    // final response = await _cartService.getCart(token);
    // if (response.statusCode == 200) {
    //   List<dynamic> cartData = response.data['items'];
    //   _cartProductIds = cartData.map((item) => item['productId'] as String).toList();
    // }
    notifyListeners();
  }

  bool isProductInCart(String productId) {
    return _cartProductIds.contains(productId);
  }

  Future<bool> addProductToCart(String productId, int quantity) async {
    if (isProductInCart(productId)) {
      log("Product already in cart: $productId");
      return false; // Indicate that it was not added (because it's already there)
    }

    _isAdding = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    log("Retrieved token: $token");
    if (token == null) {
      _isAdding = false;
      notifyListeners();
      return false; // Token missing, cannot proceed
    }

    final success = await _cartService.addToCart(
      CartRequestModel(productId: productId, quantity: quantity),
      token,
    );

    if (success) {
      // If successfully added to backend, add to our local list
      _cartProductIds.add(productId);
    }

    _isAdding = false;
    notifyListeners();
    return success;
  }
}
