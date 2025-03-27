import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  bool isNotificationEnabled = false;

  void toggleNotification() {
    isNotificationEnabled = !isNotificationEnabled;
    notifyListeners(); // Notify listeners to update UI
  }
}
