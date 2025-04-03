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

  /// Loads all products from the service
  Future<void> loadProducts() async {
    if (isLoading) return; // Prevent duplicate calls

    log("Fetching all products...");
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final fetchedProducts = await _productService.fetchProducts();

      if (fetchedProducts.isEmpty) {
        errorMessage = "No products available.";
        log(errorMessage);
      } else {
        products = fetchedProducts;
        log("Products fetched successfully. Count: ${products.length}");
      }
    } catch (e, stackTrace) {
      errorMessage = "Failed to load products: $e";
      log(errorMessage, error: e, stackTrace: stackTrace);
    }

    isLoading = false;
    notifyListeners();
  }

  /// Loads products specific to a user
  Future<void> loadProductsForUser() async {
    if (isLoading) return; // Prevent duplicate calls

    log("Fetching products for user...");
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        errorMessage = "User ID not found. Please log in again.";
        log(errorMessage);
      } else {
        final fetchedProducts = await _productService.fetchProductsForUser(userId);

        if (fetchedProducts.isEmpty) {
          errorMessage = "No products found for this user.";
          log(errorMessage);
        } else {
          products = fetchedProducts;
          log("Products fetched successfully for user: $userId. Count: ${products.length}");
        }
      }
    } catch (e, stackTrace) {
      errorMessage = "Failed to load user products: $e";
      log(errorMessage, error: e, stackTrace: stackTrace);
    }

    isLoading = false;
    notifyListeners();
  }
}