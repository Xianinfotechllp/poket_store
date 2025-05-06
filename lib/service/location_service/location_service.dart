import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:poketstore/model/location_model/location_model.dart';

class LocationService {
  final Dio _dio = Dio();
  final String baseUrl =
      'https://shop-app-backend-gsx6.onrender.com/api/user/location';

  Future<LocationModel?> fetchLocation(String userId) async {
    try {
      final response = await _dio.get('$baseUrl/$userId');
      if (response.statusCode == 200 && response.data['success']) {
        return LocationModel.fromJson(response.data['location']);
      }
    } catch (e) {
      log("❌ Error fetching location: $e");
    }
    return null;
  }

  Future<bool> updateLocation(String userId, LocationModel location) async {
    try {
      final response = await _dio.put(
        "https://shop-app-backend-gsx6.onrender.com/api/user/updatelocation/$userId",
        data: {
          "state": location.state,
          "place": location.place,
          "locality": location.locality,
          "pincode" : location.pincode,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      log("🔴 Update location error: $e");
      return false;
    }
  }
}
