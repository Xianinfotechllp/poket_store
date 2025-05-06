import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poketstore/model/home_product_model/home_product_model.dart';
import 'package:poketstore/service/home_product_service/home_product_service.dart';

class HomeProductController with ChangeNotifier {
  List<HomeProduct> _homeProducts = [];
  List<HomeProduct> get homeProducts => _homeProducts;
  final HomeProductService _service = HomeProductService();

  Future<void> loadHomeProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      log("HomeProductController: User ID not found in SharedPreferences.");
      return;
    }

    log("HomeProductController: Fetching products for userId: $userId");
    try {
      _homeProducts = await _service.fetchHomeProducts(userId);
      log("HomeProductController: Fetched ${_homeProducts.length} products.");
      for (var product in _homeProducts) {
        log(
          "HomeProductController: Product - ID: ${product.id}, Name: ${product.name}, Image: ${product.productImage}, Price: ${product.price}, Type: ${product.productType}",
        );
      }
      notifyListeners();
      log("HomeProductController: Notified listeners after fetching products.");
    } catch (e) {
      log("HomeProductController: Error fetching products: $e");
      // Optionally set an error state and notify listeners if you want to display an error message in the UI.
      // _errorMessage = "Failed to load products: $e";
      // notifyListeners();
    }
  }
}
