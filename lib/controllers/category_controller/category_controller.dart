import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/model/category_model/category_model.dart';
import 'package:poketstore/service/category_service/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  List<Category> categories = [];
  bool isLoading = false;

  Future<void> loadCategories() async {
    isLoading = true;
    notifyListeners();

    categories = await _categoryService.fetchCategories();
    isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(String name) async {
    try {
      final Category? newCategory = await _categoryService.createCategory(name);

      if (newCategory != null) {
        categories.add(newCategory); // Add the new category to the list
        notifyListeners();
        log("✅ Category added successfully: ${newCategory.name}");
      } else {
        log("⚠️ Failed to add category: Received null response");
      }
    } catch (error) {
      log("❌ Error adding category: $error");
    }
  }
}
