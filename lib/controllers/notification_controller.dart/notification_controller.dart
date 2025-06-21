import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poketstore/model/notification_model/notification_model.dart';
import 'package:poketstore/service/notification_service/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService service = NotificationService();

  List<NotificationModel> notifications = [];
  bool isLoading = false;
  String? error;

  String? get errorMessage => error;

  int get unreadCount =>
      notifications.where((n) => n.recipient.isRead == false).length;

  Future<void> loadNotificationsForCurrentUser() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        error = 'User ID not found in SharedPreferences';
        isLoading = false;
        notifyListeners();
        return;
      }

      notifications = await service.fetchNotifications(userId);
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        error = 'User ID not found in SharedPreferences';
        notifyListeners();
        return;
      }

      await service.markAsRead(notificationId, userId);

      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final updated = notifications[index].copyWith(
          recipient: Recipient(userId: userId, isRead: true),
        );
        notifications[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
