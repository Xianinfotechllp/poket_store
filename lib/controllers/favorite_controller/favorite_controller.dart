import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/model/favorite_model/get_favourite_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poketstore/service/favorite_service/favorite_service.dart';

class FavoriteProvider with ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();

  bool isLoading = false;
  bool isSuccess = false;
  bool isFavourite = false;

  Future<void> addToFavorite(String productId) async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        isSuccess = false;
        throw Exception("User ID not found in SharedPreferences.");
      }

      log("addToFavorite controller User ID: $userId"); // Log userId for debugging

      final result = await _favoriteService.addFavorite(userId, productId);
      isSuccess = result;
    } catch (e) {
      isSuccess = false;
      log("Favorite error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  List<GetFavoriteModel> favorites = [];

  Future<void> fetchFavorites() async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        favorites = [];
        throw Exception("User ID not found in SharedPreferences.");
      }

      favorites = await _favoriteService.getFavorites(userId);
    } catch (e) {
      favorites = [];
      log("Fetch favorites error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> removeFromFavorite(String productId) async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        isSuccess = false;
        throw Exception("User ID not found in SharedPreferences.");
      }

      final result = await _favoriteService.deleteFavorite(userId, productId);
      isSuccess = result;
    } catch (e) {
      isSuccess = false;
      log("Remove favorite error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
