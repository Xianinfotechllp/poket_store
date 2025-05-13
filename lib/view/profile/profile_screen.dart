import 'package:flutter/material.dart';
import 'package:poketstore/view/about_app/about_app.dart';
import 'package:poketstore/view/help/help.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/controllers/login_reg_controller/login_controller.dart';
import 'package:poketstore/controllers/user_profile_controller/user_profile_controller.dart';

import 'package:poketstore/view/add_shop/add_shop.dart';
import 'package:poketstore/view/add_shop/shope_list_screen.dart';
import 'package:poketstore/view/delivery_address/delivery_address.dart';
import 'package:poketstore/view/notification/notification.dart';
import 'package:poketstore/view/order_screen/order_screen.dart';
import 'package:poketstore/view/subscription/subscription.dart';
import 'package:poketstore/view/user_profile/user_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final userProfileController = context.watch<UserProfileController>();
    final profile = userProfileController.userProfile;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/person.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.name ?? 'Guest User',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          profile?.state ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),

            // Menu List
            // buildMenuItem(Icons.shopping_bag_outlined, "Orders", () {
            //   Navigator.push(context,
            //       MaterialPageRoute(builder: (context) => OrdersScreen()));
            // }),
            buildMenuItem(Icons.person_outline, "My Details", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserProfileScreen()));
            }),
            buildMenuItem(Icons.location_on_outlined, "Delivery Address", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DeliveryScreen()));
            }),
            // buildMenuItem(Icons.payment_outlined, "Payment Methods", () {}),
            buildMenuItem(Icons.add_business_outlined, "Add Shop", () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ShopListScreen()));
            }),
            // buildMenuItem(Icons.card_giftcard_outlined, "Promo Code", () {}),
            // buildMenuItem(Icons.subscriptions_outlined, "Subscription", () {
            //   Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => const Subscription()));
            // }),
            // buildMenuItem(Icons.notifications_outlined, "Notifications", () {
            //   Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => const NotificationScreen()));
            // }),
            buildMenuItem(Icons.help_outline, "Help", () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HelpScreen()));
            }),
            buildMenuItem(Icons.info_outline, "About", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AboutAppScreen()));
            }),

            const SizedBox(height: 20),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  loginProvider.logout(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFF094497),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Log Out",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Reusable menu item builder
  Widget buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
