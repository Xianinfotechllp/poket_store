import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poketstore/model/location_model/location_model.dart';
import 'package:poketstore/service/location_service/location_service.dart';

class LocationController with ChangeNotifier {
  LocationModel? location;
  bool isLoading = false;
  String? error;

  final LocationService _service = LocationService();

  Future<void> getLocation() async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        error = "User ID not found";
        isLoading = false;
        notifyListeners();
        return;
      }

      location = await _service.fetchLocation(userId);

      if (location == null) {
        error = "Failed to fetch location";
      }
    } catch (e) {
      error = "An error occurred: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateLocationFromGPS(LocationModel newLocation) async {
    isLoading = true;
    notifyListeners();

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
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        error = "Unable to determine address.";
        isLoading = false;
        notifyListeners();
        return;
      }

      Placemark place = placemarks.first;
      final newLocation = LocationModel(
        state: place.administrativeArea ?? '',
        place: place.subAdministrativeArea ?? '',
        locality: place.locality ?? '',
        pincode: place.postalCode ?? '',
      );

      final success = await _service.updateLocation(userId, newLocation);

      if (success) {
        location = newLocation;
      } else {
        error = "Failed to update location";
      }
    } catch (e) {
      error = "An error occurred while updating: $e";
    }

    isLoading = false;
    notifyListeners();
  }
}
