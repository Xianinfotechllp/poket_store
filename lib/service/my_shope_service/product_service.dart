import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:poketstore/model/my_shope_model/product_model.dart';

class ProductService {
  final Dio _dio = Dio();
  final String baseUrl =
      "https://shop-app-backend-main.onrender.com/api/products";

  /// Add Product////

  Future<Product?> createProduct({
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
    try {
      FormData formData = FormData.fromMap({
        "productImage": await MultipartFile.fromFile(
          productImage.path,
          filename: productImage.path.split('/').last,
        ),
        "name": name,
        "description": description,
        "price": price.toString(),
        "quantity": quantity.toString(),
        "category": category,
        "estimatedTime": estimatedTime,
        "productType": productType,
        "deliveryOption": deliveryOption,
      });

      Response response = await _dio.post(baseUrl, data: formData);
      log("Create product response: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Product.fromJson(response.data['product']);
      } else {
        return null;
      }
    } catch (e) {
      log("Error creating product: $e");
      return null;
    }
  }

  /// Fetch Product ///

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _dio.get(baseUrl);
      log("Response Data: ${response.data}"); // Log the full response
      log("Status Code: ${response.statusCode}"); // Log status code
      if (response.statusCode == 200) {
        List<dynamic> productsJson = response.data["products"];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch products");
      }
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }

  ///Details page///

  Future<Product> fetchProduct(String productId) async {
    try {
      final response = await _dio.get("$baseUrl/$productId");

      log(
        "fetchProduct response: ${response.data}",
      ); // Log the entire response data

      if (response.statusCode == 200) {
        return Product.fromJson(response.data["product"]);
      } else {
        log(
          "fetchProduct failed with status code: ${response.statusCode}",
        ); // Log the status code
        throw Exception("Failed to fetch product");
      }
    } catch (e) {
      log("fetchProduct error: $e"); // Log the error
      throw Exception("Error: $e");
    }
  }

  ///for user product//

  Future<List<Product>> fetchProductsForUser(String userId) async {
    try {
      final response = await _dio.get(
        "https://shop-app-backend-main.onrender.com/api/products/user/$userId",
      );
      log("Response Data: ${response.data}"); // Log the full response
      log("Status Code: ${response.statusCode}"); // Log status code
      if (response.statusCode == 200) {
        List<dynamic> productsJson = response.data["products"];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch products");
      }
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }

  Future<bool> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put("$baseUrl/update/$productId", data: data);
      if (response.statusCode == 200) {
        log("Product updated successfully: ${response.data}");
        return true;
      }
    } catch (e) {
      log("Error updating product: $e");
    }
    return false;
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      final response = await _dio.delete("$baseUrl/$productId");
      if (response.statusCode == 200) {
        log("Product deleted successfully");
        return true;
      }
    } catch (e) {
      log("Error deleting product: $e");
    }
    return false;
  }
}
