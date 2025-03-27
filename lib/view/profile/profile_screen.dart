import 'package:flutter/material.dart';
import 'package:poketstore/controllers/login_reg_controller/login_controller.dart';
import 'package:poketstore/view/add_shop/add_shop.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
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
                  // Profile Image
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(
                      'assets/person.png',
                    ), // Replace with actual image URL
                  ),
                  const SizedBox(width: 12),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'James Anderson',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Example@gmail.com',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  // Edit Icon
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, color: Colors.green),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),

            // Menu List
            buildMenuItem(Icons.shopping_bag_outlined, "Orders", () {}),
            buildMenuItem(Icons.person_outline, "My Details", () {}),
            buildMenuItem(
              Icons.location_on_outlined,
              "Delivery Address",
              () {},
            ),
            buildMenuItem(Icons.payment_outlined, "Payment Methods", () {}),
            buildMenuItem(Icons.add_business_outlined, "Add Shop", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddShop()),
              );
            }),
            buildMenuItem(Icons.card_giftcard_outlined, "Promo Cord", () {}),
            buildMenuItem(Icons.notifications_outlined, "Notifications", () {}),
            buildMenuItem(Icons.help_outline, "Help", () {}),
            buildMenuItem(Icons.info_outline, "About", () {}),

            const SizedBox(height: 20),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  loginProvider.logout(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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

  // Function to create each menu item
  Widget buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap, // Add navigation here
    );
  }
}
