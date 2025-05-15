import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About PocketStore'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              '📱 PocketStore',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'PocketStore is your personalized online marketplace where every user can become a seller and a shopper. '
              'Whether you\'re managing your own shop or browsing products from others, PocketStore brings convenience, control, and community all in one place.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              '🔑 Key Features:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '🛍 Register and Manage Your Own Shop\n'
              'Set up your store easily and manage your product listings directly from the app.\n\n'
              '📦 Add and Showcase Products\n'
              'Upload products with details and images to attract potential buyers.\n\n'
              '❤️ Favorites List\n'
              'Save your favorite products for quick access and future purchases.\n\n'
              '🏷 Promo Codes & Subscriptions\n'
              'Use promo codes for special offers and enjoy exclusive deals through subscriptions.\n\n'
              '📍 Save Delivery Addresses\n'
              'Store and manage multiple delivery addresses for faster checkout.\n\n'
              '👥 Community-Based Marketplace\n'
              'Explore shops from other users, support local businesses, and build your own customer base.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
