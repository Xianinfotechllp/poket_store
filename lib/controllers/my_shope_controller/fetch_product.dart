import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/model/my_shope_model/product_model.dart';
import 'package:poketstore/service/my_shope_service/product_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FetchProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  List<Product> products = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> loadProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      products = await _productService.fetchProducts();
      errorMessage = '';
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  //for user product

  Future<void> loadProductsForUser() async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        errorMessage = "User ID not found. Please log in again.";
        log(errorMessage);
      } else {
        products = await _productService.fetchProductsForUser(userId);
        errorMessage = '';
        log("Products fetched successfully for user: $userId");
      }
    } catch (e) {
      errorMessage = "Failed to load products: $e";
      log(errorMessage);
    }

    isLoading = false;
    notifyListeners();
  }
}
