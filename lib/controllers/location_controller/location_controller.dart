import 'package:flutter/material.dart';
import 'package:poketstore/model/location_model/location_model.dart';
import 'package:poketstore/service/location_service/location_service.dart';

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
      String userId, LocationMapModel newLocation) async {
    isLoading = true;
    notifyListeners();

    final updated = await _service.updateLocation(userId, newLocation);
    if (updated != null) {
      locationMap = updated;
    }

    isLoading = false;
    notifyListeners();
  }
}
