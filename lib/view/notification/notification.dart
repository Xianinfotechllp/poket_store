import 'package:flutter/material.dart';
import 'package:poketstore/controllers/notification_controller.dart/notification_controller.dart';
import 'package:poketstore/controllers/notification_provider.dart';
import 'package:poketstore/view/notification/notification_details.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

// Import the new detail screen// Adjust path if needed

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<NotificationProvider>().loadNotificationsForCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 7, 3, 201),
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Chip(
              side: BorderSide.none,
              label: Text(
                'Unread: ${notificationProvider.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 7, 3, 201),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Builder(
              builder: (context) {
                if (notificationProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (notificationProvider.errorMessage != null &&
                    notificationProvider.notifications.isEmpty) {
                  return Center(
                    child: Text(notificationProvider.errorMessage!),
                  );
                }
                if (notificationProvider.notifications.isEmpty) {
                  return const Center(child: Text("No notifications yet."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: notificationProvider.notifications.length,
                  itemBuilder: (context, index) {
                    final notification =
                        notificationProvider.notifications[index];

                    final isRead = notification.recipient.isRead;
                    final backgroundColor =
                        isRead ? Colors.white.withOpacity(0.7) : Colors.white;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color:
                                    isRead
                                        ? Colors.grey[300]!
                                        : Colors.blueAccent.withOpacity(0.5),
                                width: 1.2,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              leading: CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                    isRead
                                        ? Colors.grey[300]
                                        : Colors.blueAccent,
                                child: Icon(
                                  isRead
                                      ? Icons.notifications_active
                                      : Icons.notifications_active_outlined,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      isRead
                                          ? FontWeight.w500
                                          : FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  notification.body,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              trailing: Text(
                                '${notification.createdAt.day}/${notification.createdAt.month} ${notification.createdAt.hour}:${notification.createdAt.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                              onTap: () {
                                // Mark as read and navigate to detail screen
                                context.read<NotificationProvider>().markAsRead(
                                  notification.id,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => NotificationDetailScreen(
                                          notification: notification,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
