import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/service/notification(fcm)_service.dart/notification(fcm)_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poketstore/model/fcm_model/fcm_model.dart';
import 'package:poketstore/service/fcm_service/fcm_service.dart';

class FCMProvider extends ChangeNotifier {
  final FCMService service = FCMService();
  final FirebasePushService _firebasePushService = FirebasePushService();
  bool isLoading = false;
  String? message;
  String? error;

  Future<void> registerFcmToken(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      // 1. Initialize Firebase Push Notification Service
      await _firebasePushService.init(context);

      // 2. Get FCM token from Firebase
      final fcmToken = await _firebasePushService.getToken();
      log("Retrieved FCM Token: $fcmToken");

      if (fcmToken == null) {
        error = "Failed to retrieve FCM token.";
        return;
      }

      // 3. Get user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        error = "User ID not found in SharedPreferences.";
        return;
      }

      // 4. Create FCMModel and send to API
      final model = FCMModel(userId: userId, fcmToken: fcmToken);
      final result = await service.saveFcmToken(model);

      // 5. Handle result
      if (result != null) {
        message = result;
        error = null;
      } else {
        message = null;
        error = "Failed to save FCM token.";
      }
    } catch (e) {
      error = "An error occurred: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
