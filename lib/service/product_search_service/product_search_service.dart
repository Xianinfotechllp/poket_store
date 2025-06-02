// poketstore/services/product_search_service/product_search_service.dart
// import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart'; // Import the dio package
import 'package:poketstore/model/product_search_model/product_search_model.dart';

// Service class to handle API calls for product search.
class ProductSearchService {
  // Base URL for the product search API.
  static const String _baseUrl =
      'http://shopappsabufree.work.gd:8000/api/products/search';
  final Dio _dio = Dio(); // Create a Dio instance

  // Method to search for products based on product name and/or locality.
  // If a parameter is empty, 'null' string is passed to the API.
  Future<List<ProductSearchModel>> searchProducts(
      String productName, String locality) async {
    try {
      // Replace empty strings with 'null' for API compatibility.
      final String nameParam = productName.isEmpty ? 'null' : productName;
      final String localityParam = locality.isEmpty ? 'null' : locality;

      // Construct the API URL.
      final String url = '$_baseUrl/$nameParam/$localityParam';
      log('Searching products at: $url'); // Log the constructed URL

      final response = await _dio.get(url); // Use Dio for the GET request

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            response.data; // Dio automatically decodes JSON
        if (responseData['success'] == true) {
          final List<dynamic> productListJson = responseData['data'];
          // Map the list of JSON objects to a list of ProductSearchModel objects.
          return productListJson
              .map((json) => ProductSearchModel.fromJson(json))
              .toList();
        } else {
          // Handle API success: false case.
          throw Exception(
              responseData['message'] ?? 'Failed to search products');
        }
      } else {
        // Handle HTTP error status codes.
        throw Exception(
            'Failed to load products. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Catch DioException for network-related errors
      log('Dio Error searching products: ${e.message}');
      if (e.response != null) {
        log('Dio Error Response Data: ${e.response?.data}');
        log('Dio Error Response Headers: ${e.response?.headers}');
        log('Dio Error Response Request Options: ${e.response?.requestOptions}');
        throw Exception(
            'Failed to search products: ${e.response?.data['message'] ?? e.message}');
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        throw Exception('Error sending request: ${e.message}');
      }
    } catch (e) {
      // Catch any other exceptions during the process.
      log('Unexpected Error searching products: $e');
      throw Exception('Unexpected error searching products: $e');
    }
  }
}
