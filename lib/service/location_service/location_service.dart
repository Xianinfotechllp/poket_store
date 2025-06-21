import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poketstore/model/location_model/location_model.dart';

class LocationMapService {
  final Dio dio = Dio();

  Future<LocationMapModel?> fetchUserLocation(String userId) async {
    try {
      final response = await dio.get(
        'https://shop-app-backend-gsx6.onrender.com/api/user/location/$userId',
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return LocationMapModel.fromJson(response.data);
      }
    } catch (e) {
      log('Error fetching location: $e');
    }
    return null;
  }

  Future<LocationMapModel?> updateLocation(
    String userId,
    LocationMapModel location,
  ) async {
    try {
      final response = await dio.put(
        'https://shop-app-backend-gsx6.onrender.com/api/user/updatelocation/$userId',
        data: location.toJson(),
      );

      // ✅ Log the full response data and status code
      log(
        "📡 Location update response [${response.statusCode}]: ${response.data}",
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return LocationMapModel.fromJson(response.data['location']);
      } else {
        log(
          "⚠️ Server returned an error: ${response.data['message'] ?? 'Unknown error'}",
        );
        return null;
      }
    } catch (e) {
      log("❌ Error updating location: $e");
      return null;
    }
  }
}
