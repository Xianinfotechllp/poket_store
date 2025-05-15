import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poketstore/model/user_profile_model/user_profile_model.dart';
import 'package:poketstore/service/user_profile_service/user_profile_service.dart';

class UserProfileController extends ChangeNotifier {
  final UserProfileService _service = UserProfileService();

  UserProfile? userProfile;
  bool isLoading = false;
  String? error;

  Future<void> loadUserProfile(String userId) async {
    isLoading = true;
    notifyListeners();

    final profile = await _service.fetchUserProfile(userId);
    if (profile != null) {
      userProfile = profile;
      error = null;
    } else {
      error = 'Failed to load profile';
    }

    isLoading = false;
    notifyListeners();
  }

  /// ✅ New method to load user profile from SharedPreferences
  Future<void> loadUserProfileFromPrefs() async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null && userId.isNotEmpty) {
      await loadUserProfile(userId);
    } else {
      error = 'User ID not found in preferences';
      isLoading = false;
      notifyListeners();
    }
  }
}
