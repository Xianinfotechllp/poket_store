// poketstore/controllers/favorite_controller/favorite_controller.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/model/favorite_model/get_favourite_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poketstore/service/favorite_service/favorite_service.dart';

class FavoriteProvider with ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();

  bool isLoading = false;
  bool isSuccess = false;
  bool isFavourite =
      false; // This might be used for individual product favorite status
  String errorMessage = ''; // <--- Add this line

  Future<void> addToFavorite(String productId) async {
    isLoading = true;
    errorMessage = ''; // Clear previous error
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        isSuccess = false;
        errorMessage =
            "User ID not found. Please log in again."; // Set specific error
        throw Exception(errorMessage);
      }

      log("addToFavorite controller User ID: $userId");

      final result = await _favoriteService.addFavorite(userId, productId);
      isSuccess = result;
      if (isSuccess) {
        // Optionally, you might want to refetch the list or add the item locally
        // if your UI needs to immediately reflect the addition.
        // A full refetch might be safer for complex scenarios.
        await fetchFavorites(); // Refresh the list after adding
      }
    } catch (e) {
      isSuccess = false;
      errorMessage = e.toString(); // Capture the error message
      log("Favorite error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<GetFavoriteModel> favorites = [];

  Future<void> fetchFavorites() async {
    isLoading = true;
    errorMessage = ''; // Clear previous error
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        favorites = [];
        errorMessage =
            "User ID not found. Please log in again."; // Set specific error
        throw Exception(errorMessage);
      }

      favorites = await _favoriteService.getFavorites(userId);
    } catch (e) {
      favorites = [];
      errorMessage = e.toString(); // Capture the error message
      log("Fetch favorites error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromFavorite(String productId) async {
    isLoading = true;
    errorMessage = ''; // Clear previous error
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        isSuccess = false;
        errorMessage =
            "User ID not found. Please log in again."; // Set specific error
        throw Exception(errorMessage);
      }

      final result = await _favoriteService.deleteFavorite(userId, productId);
      isSuccess = result;
      if (isSuccess) {
        // Remove the item from the local list directly for immediate UI update
        favorites.removeWhere((item) => item.id == productId);
        // Or for robustness, you could refetch:
        // await fetchFavorites();
      }
    } catch (e) {
      isSuccess = false;
      errorMessage = e.toString(); // Capture the error message
      log("Remove favorite error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
