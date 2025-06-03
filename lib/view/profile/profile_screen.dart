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
import 'package:poketstore/controllers/bottom_bar_controller/bottombar_controller.dart'; // Import BottomBarProvider

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final userProfileController = context.watch<UserProfileController>();
    final profile = userProfileController.userProfile;
    final bottomBarProvider = Provider.of<BottomBarProvider>(context,
        listen:
            false); // Get BottomBarProvider instance.  Use listen: false, as we don't want to rebuild this widget when the bottom bar changes.

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // const SizedBox(height: 40),

            // Top blue bar with "Poket Stor"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 7, 3, 201),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: 'Poket',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'Stor',
                        style: TextStyle(color: Color(0xFFFFEA00)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Menu List
            // buildMenuItem(Icons.shopping_bag_outlined, "Orders", () {
            //   Navigator.push(context,
            //       MaterialPageRoute(builder: (context) => OrdersScreen()));
            // }),
            buildMenuItem(Icons.person_outline, "My Details", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserProfileScreen()));
            }),
            // buildMenuItem(Icons.location_on_outlined, "Delivery Address", () {
            //   Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => const DeliveryScreen()));
            // }),
            // buildMenuItem(Icons.payment_outlined, "Payment Methods", () {}),
            buildMenuItem(Icons.add_business_outlined, "Add Shop", () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ShopListScreen()));
            }),
            // buildMenuItem(Icons.card_giftcard_outlined, "Promo Code", () {}),
            // buildMenuItem(Icons.subscriptions_outlined, "Subscription", () {
            //   Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => const Subscription()));
            // }),
            // buildMenuItem(Icons.notifications_outlined, "Notifications", () {
            //   Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => const NotificationScreen()));
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
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm Logout"),
                        content:
                            const Text("Are you sure you want to log out?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close dialog
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close dialog
                              loginProvider.logout(context);
                              bottomBarProvider
                                  .changeTab(0); // Change bottom tab
                            },
                            child: const Text("Logout"),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 7, 3, 201),
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
