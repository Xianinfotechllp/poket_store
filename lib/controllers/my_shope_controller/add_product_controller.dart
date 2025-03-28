import 'dart:io';
import 'package:flutter/material.dart';
import 'package:poketstore/model/my_shope_model/product_model.dart';
import 'package:poketstore/service/my_shope_service/product_service.dart';
import 'dart:developer'; // Import the developer library

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  Product? product;
  bool isLoading = false;
  String? errorMessage;

  Future<void> createProduct({
    required File productImage,
    required String name,
    required String description,
    required int price,
    required int quantity,
    required List<String> category,
    required String estimatedTime,
    required String productType,
    required String deliveryOption,
  }) async {
    isLoading = true;
    notifyListeners();

    log("Creating product with data:");
    log("Product Image: ${productImage.path}");
    log("Name: $name");
    log("Description: $description");
    log("Price: $price");
    log("Quantity: $quantity");
    log("Category: $category");
    log("Estimated Time: $estimatedTime");
    log("Product Type: $productType");
    log("Delivery Option: $deliveryOption");

    product = await _productService.createProduct(
      productImage: productImage,
      name: name,
      description: description,
      price: price,
      quantity: quantity,
      category: category,
      estimatedTime: estimatedTime,
      productType: productType,
      deliveryOption: deliveryOption,
    );

    if (product != null) {
      log("Product created successfully!");
    } else {
      log("Failed to create product.");
    }

    isLoading = false;
    notifyListeners();
  }

  /// Fetch product details ///

  Future<void> fetchProduct(String productId) async {
    isLoading = true;
    notifyListeners();

    try {
      product = await _productService.fetchProduct(productId);
      log("Product fetched successfully: ${product?.name}");
    } catch (e) {
      log("Error fetching product: $e");
      product = null; // Set product to null on error
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    bool success = await _productService.updateProduct(productId, data);
    if (success) {
      // Refresh product details
      fetchProduct(productId);
    }
    return success;
  }

  Future<bool> deleteProduct(String productId) async {
    bool success = await _productService.deleteProduct(productId);
    if (success) {
      product = null;
      notifyListeners();
    }
    return success;
  }
}
