import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/location_model/location_model.dart';

class LocationService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://shop-app-backend-gsx6.onrender.com/api/user';

  Future<LocationModel?> fetchLocation(String userId) async {
    try {
      final response = await _dio.get('$baseUrl/location/$userId');
      if (response.statusCode == 200 && response.data['success']) {
        log('Location fetched successfully: ${response.data}');
        return LocationModel.fromJson(response.data['location']);
      } else {
        log('Failed to fetch location. Status code: ${response.statusCode}, Response: ${response.data}');
        return null; // Explicitly return null for consistency
      }
    } catch (e) {
      log('Error fetching location: $e');
      return null; // Explicitly return null on error
    }
  }

  Future<bool> updateLocation(String userId, LocationModel location) async {
    try {
      final response = await _dio.put(
        '$baseUrl/updatelocation/$userId',
        data: location.toJson(),
      );
      if (response.statusCode == 200) {
        log('Location updated successfully: ${response.data}');
        return true;
      } else {
        log('Failed to update location. Status code: ${response.statusCode}, Response: ${response.data}');
        return false;
      }
    } catch (e) {
      log('Error updating location: $e');
      return false;
    }
  }
}
