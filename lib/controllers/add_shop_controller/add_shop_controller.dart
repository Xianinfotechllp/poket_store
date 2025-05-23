import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/model/my_shope_model/shope_details_model.dart';
import 'package:poketstore/service/add_shop_service/add_shop_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopProvider with ChangeNotifier {
  final ShopService _shopService = ShopService();
  List<ShopModel> shops = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchShops() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      shops = await _shopService.fetchShops();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addShop(ShopModel shop, File? imageFile) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      await _shopService.addShop(shop, imageFile);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateShop(
    ShopeDetailsModel shopDetails,
  ) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      if (shopDetails.id.isEmpty) {
        // Check for empty ID as well
        throw Exception("Shop ID is required for updating.");
      }

      // Fetch the token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception("Authentication token not found. Please log in again.");
      }

      // Pass the ID, shopDetails, newImageFile, and token to the service
      await _shopService.updateShop(shopDetails.id, shopDetails, token);
      errorMessage = ""; // Clear error message on success
      log("✅ Shop updated successfully!");
    } catch (e) {
      errorMessage = e.toString();
      log("❌ Provider error updating shop: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteShop(String shopId) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      await _shopService.deleteShop(shopId);
      errorMessage = ""; // Clear error message on success
      log("✅ Shop deleted successfully!");
    } catch (e) {
      errorMessage = e.toString();
      log("❌ Provider error deleting shop: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
