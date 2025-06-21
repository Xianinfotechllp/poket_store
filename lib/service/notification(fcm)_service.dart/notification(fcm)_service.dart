import 'dart:developer'; // For logging
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:poketstore/controllers/notification_provider.dart';
import 'package:provider/provider.dart'; // Required for BuildContext, ScaffoldMessenger, SnackBar, Colors

class FirebasePushService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Modify init to accept a BuildContext
  Future<void> init(BuildContext context) async {
    // Request permission (iOS) and check status for Android
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    log('User notification permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted full permission for notifications.');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('User granted provisional permission (iOS only).');
    } else {
      log('User declined or has not accepted notification permission.');
    }

    // Get and log FCM token
    String? token = await _messaging.getToken();
    log("FCM Token: $token");

    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("🔔 Foreground Notification Received!");
      log("Message data: ${message.data}");
      if (message.notification != null) {
        log("Notification Title: ${message.notification?.title}");
        log("Notification Body: ${message.notification?.body}");

        // --- SHOW SNACKBAR FOR FOREGROUND NOTIFICATION ---
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${message.notification!.title ?? 'New Notification'}\n${message.notification!.body ?? ''}",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black87, // Dark background for the snackbar
            duration: const Duration(seconds: 4), // Duration for the snackbar
            behavior: SnackBarBehavior.floating, // Make it float (like a toast)
            margin: const EdgeInsets.all(10), // Add some margin
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        // --- END SNACKBAR ---
      }
    });

    // Handle messages when app is opened from background/terminated state
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("🔔 Foreground Notification Received!");
      final title = message.notification?.title ?? 'No Title';
      final body = message.notification?.body ?? 'No Body';

      // Add to provider
      // final provider = Provider.of<NotificationProvider>(
      //   context,
      //   listen: false,
      // );
      // provider.addFcmMessage(title, body);

      // Show SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$title\n$body"),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });

    // Register top-level function for background messages
    // IMPORTANT: _firebaseMessagingBackgroundHandler CANNOT use SnackBar
    // directly as it runs in an isolated context without UI access.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // New method to retrieve the FCM token
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}

// Must be outside any class and registered in main()
@pragma('vm:entry-point') // Required for background execution
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background messages
  await Firebase.initializeApp();
  log("🔙 Handling background message: ${message.messageId}");
  log("Background message data: ${message.data}");
  if (message.notification != null) {
    log("Background notification title: ${message.notification?.title}");
    log("Background notification body: ${message.notification?.body}");
  }
  // For background/terminated messages, you typically use `flutter_local_notifications`
  // to display a notification that the user can see outside the app.
  // You cannot use SnackBar here directly.
}
