import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poketstore/model/home_product_model/home_product_model.dart';

class HomeProductService {
  final Dio _dio = Dio();

  Future<List<ShopWithProducts>> fetchHomeProducts(String userId) async {
    try {
      final response = await _dio.get(
        'https://shop-app-backend-gsx6.onrender.com/api/products/nearbyshop/$userId',
      );

      if (response.statusCode == 200) {
        // Check if response.data is not null and is a Map
        if (response.data != null && response.data is Map) {
          // Check for the presence of the 'data' key and if its value is a List
          if (response.data.containsKey('data') &&
              response.data['data'] is List) {
            List<dynamic> shopDataList = response.data['data'];
            // Map the list of dynamic to a list of ShopWithProducts objects
            return shopDataList
                .map((shopData) => ShopWithProducts.fromJson(shopData))
                .toList();
          } else {
            log('HomeProductService: The key "data" is missing or is not a list.');
            return []; // Return an empty list
          }
        } else {
          log('HomeProductService: Unexpected response structure. Expected a Map.');
          return []; // Return an empty list
        }
      } else {
        log('HomeProductService: Failed to load products. Status code: ${response.statusCode}');
        return []; // Return an empty list
      }
    } catch (e) {
      log('HomeProductService: Error fetching products: $e');
      return Future.error(
          e); // Important: rethrow the error to be caught by the caller
    }
  }
}
