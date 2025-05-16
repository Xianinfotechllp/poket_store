import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/model/home_product_model/home_product_model.dart';
import 'package:poketstore/service/home_product_service/home_product_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProductController with ChangeNotifier {
  List<LocationProduct> products = [];
  //List<LocationProduct> get products => _products;  Removed Getter

  final LocationProductService _service = LocationProductService();
  bool isLoading = false;
  //bool get isLoading => _isLoading;  Removed Getter

  String? errorMessage;
  //String? get errorMessage => _errorMessage;  Removed Getter

  // Load products based on User ID
  Future<void> loadProducts() async {
    isLoading = true;
    errorMessage = null; //Reset Error
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        errorMessage = "User ID not found.";
        isLoading = false;
        notifyListeners();
        log('LocationProductProvider: User ID is null');
        return;
      }

      products = await _service.fetchProductsByUserId(userId);
      isLoading = false;
      notifyListeners();
      log('LocationProductProvider: Loaded ${products.length} products for user: $userId');
    } catch (error) {
      errorMessage = "Failed to load products: $error";
      isLoading = false;
      notifyListeners();
      log('LocationProductProvider: Error - $error');
    }
  }

  //Method to clear the products.
  void clearProducts() {
    products.clear();
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }
}
