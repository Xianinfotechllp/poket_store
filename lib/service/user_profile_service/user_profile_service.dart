import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:poketstore/model/user_profile_model/user_profile_model.dart';

class UserProfileService {
  final Dio _dio = Dio();

  Future<UserProfile?> fetchUserProfile(String userId) async {
    try {
      final response = await _dio.get(
        'http://shopappsabufree.work.gd:8000/api/user/details/$userId',
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserProfile.fromJson(response.data);
      }
    } catch (e) {
      log('Error fetching user profile: $e');
    }
    return null;
  }
}
