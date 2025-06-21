import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:poketstore/model/location_model/location_model.dart';
import 'package:poketstore/service/location_service/location_service.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator
import 'package:shared_preferences/shared_preferences.dart'; // To get userId

class LocationMapController extends ChangeNotifier {
  final LocationMapService _service = LocationMapService();

  LocationMapModel? locationMap;
  bool isLoading = false;
  String? error;

  Future<void> loadUserLocation(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      locationMap = await _service.fetchUserLocation(userId);
      error = locationMap == null ? "Failed to fetch location" : null;
    } catch (e) {
      error = "Error: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserLocation(
    String userId,
    LocationMapModel newLocation,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      log(
        "🔄 Updating user location for userId: $userId with data: ${newLocation.toJson()}",
      );
      final updated = await _service.updateLocation(userId, newLocation);
      if (updated != null) {
        locationMap = updated;
        error = null;
        log("✅ Location updated successfully: ${updated.toJson()}");
      } else {
        error = "Failed to update location on the server.";
        log("⚠️ Location update failed, received null.");
      }
    } catch (e) {
      error = "Error updating location: $e";
      log("❌ Exception in updateUserLocation: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// NEW: Fetches the current device's location and saves it for the user.
  Future<void> getCurrentAndSaveUserLocation() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Step 1: Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        error = 'Location services are disabled. Please enable them.';
        isLoading = false;
        notifyListeners();
        return;
      }

      // Step 2: Request permission if not already granted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          error = 'Location permission denied.';
          isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        error =
            'Location permission permanently denied. Please allow in app settings.';
        isLoading = false;
        notifyListeners();
        return;
      }

      // Step 3: Get current device position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Step 4: Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        error = 'Unable to get address from coordinates.';
        isLoading = false;
        notifyListeners();
        return;
      }

      Placemark place = placemarks.first;

      // Debug log each field
      log(
        "🏷 Placemark info: name=${place.name}, locality=${place.locality}, "
        "state=${place.administrativeArea}, postalCode=${place.postalCode}",
      );

      // Step 5: Get user ID
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null || userId.isEmpty) {
        error = "User not logged in. Cannot save location.";
        isLoading = false;
        notifyListeners();
        return;
      }

      // Step 6: Create location model
      LocationMapModel newLocation = LocationMapModel(
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
        locality: place.locality ?? '',
        state: place.administrativeArea ?? '',
        pincode: place.postalCode ?? '',
        place: place.name ?? '',
      );

      // Log model values
      log("📍 Prepared location: ${newLocation.toJson()}");

      // Step 7: Save to server
      await updateUserLocation(userId, newLocation);
    } catch (e) {
      error = "Failed to get/save location: $e";
      log("❌ Exception in getCurrentAndSaveUserLocation: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
