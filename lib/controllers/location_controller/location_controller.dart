import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poketstore/model/location_model/location_model.dart';
import 'package:poketstore/service/location_service/location_service.dart';

class LocationController with ChangeNotifier {
  LocationModel? _location; // Make location private
  LocationModel? get location => _location; // Provide a getter for accessing it
  bool isLoading = false;
  String? error;

  final LocationService _service = LocationService();

  LocationController() {
    //removed call to get location.
    log("LocationController initialized");
  }

  Future<void> getLocation(String userId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    log("Fetching location...");
    _location = await _service.fetchLocation(userId); // Await the result
    if (_location != null) {
      log("Location data loaded: ${_location?.toJson()}");
    } else {
      log("Location data is null after fetch");
      error = "Failed to fetch location"; //set error
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateLocationFromGPS() async {
    isLoading = true;
    error = null;
    notifyListeners();
    log("Updating location from GPS...");

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        error = "User ID not found";
        isLoading = false;
        notifyListeners();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isEmpty) {
        error = "Unable to determine address.";
        isLoading = false;
        notifyListeners();
        return;
      }

      Placemark place = placemarks.first;
      final newLocation = LocationModel(
        state: place.administrativeArea ?? '',
        place: place.locality ?? '',
        locality: place.subLocality ?? '',
        pincode: place.postalCode ?? '',
      );

      final success = await _service.updateLocation(userId, newLocation);
      if (success) {
        _location =
            newLocation; // Update the internal _location, not create new variable
        log("Location updated successfully: ${_location?.toJson()}");
      } else {
        error = "Failed to update location";
        log("Failed to update location in service");
      }
    } catch (e) {
      error = "An error occurred while updating: $e";
      log("Error updating location: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
