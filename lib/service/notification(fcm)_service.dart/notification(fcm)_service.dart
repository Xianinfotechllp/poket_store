import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebasePushService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Request permission (iOS only)
    await _messaging.requestPermission();

    // Get and log FCM token
    String? token = await _messaging.getToken();
    log("FCM Token: $token");

    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("🔔 Foreground Notification: ${message.notification?.title}");
    });

    // Handle messages when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("📲 Notification Clicked!");
    });

    // Handle messages in background (must be a top-level function)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

// Must be outside any class
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("🔙 Background message: ${message.messageId}");
}
