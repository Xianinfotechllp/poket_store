import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poketstore/model/location_model/location_model.dart';

class LocationMapService {
  final Dio dio = Dio();

  Future<LocationMapModel?> fetchUserLocation(String userId) async {
    try {
      final response = await dio.get(
        'https://ec2-13-233-1-147.ap-south-1.compute.amazonaws.com:8000/api/user/location/$userId',
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
      String userId, LocationMapModel location) async {
    try {
      final response = await dio.put(
        'http://shopappsabufree.work.gd:8000/api/user/updatelocation/$userId',
        data: location.toJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return LocationMapModel.fromJson(response.data['location']);
      } else {
        return null;
      }
    } catch (e) {
      log("Error updating location: $e");
      return null;
    }
  }
}
