import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poketstore/model/category_model/category_model.dart';

class CategoryService {
  final Dio _dio = Dio();
  final String _baseUrl =
      "https://shop-app-backend-main.onrender.com/api/category";
  Future<List<Category>> fetchCategories() async {
    try {
      final response = await _dio.get(_baseUrl);

      if (response.statusCode == 200) {
        List<Category> categories =
            (response.data['categories'] as List)
                .map((json) => Category.fromJson(json))
                .toList();
        return categories;
      } else {
        throw Exception("Failed to load categories");
      }
    } catch (e) {
      log("Error fetching categories: $e");
      return [];
    }
  }

  Future<Category?> createCategory(String name) async {
    try {
      log("🔹 Sending request to add category: $name");

      final response = await _dio.post(_baseUrl, data: {"name": name});

      log("✅ Response Status Code: ${response.statusCode}");
      log("✅ Response Data: ${response.data}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Category.fromJson(response.data);
      } else {
        log("⚠️ Unexpected status code: ${response.statusCode}");
        return null;
      }
    } on DioException catch (e) {
      log("❌ Dio Error: ${e.response?.statusCode} - ${e.response?.data}");
      throw Exception("Failed to add category: ${e.response?.data}");
    } catch (e) {
      log("❌ Unknown Error: $e");
      throw Exception("Failed to add category");
    }
  }
}
