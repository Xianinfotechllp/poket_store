import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:poketstore/view/cart/cart_screen.dart';
import 'package:poketstore/view/favourite/favourite_screen.dart';
import 'package:poketstore/view/home/home_screen.dart';
import 'package:poketstore/view/my_shop/my_shop_screen.dart';
import 'package:poketstore/view/profile/profile_screen.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  int _selectedIndex = 0; // Track selected index

  // List of screens to display for each tab
  final List<Widget> _screens = [
    HomeScreen(),
    MyShopScreen(),
    CartScreen(),
    FavouriteScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: GNav(
            backgroundColor: Colors.white,
            color: Colors.black,
            activeColor: Colors.black,
            gap: 8,
            tabBackgroundColor: Colors.grey.shade300,
            padding: EdgeInsets.all(10),
            selectedIndex: _selectedIndex, // Highlight selected tab
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index; // Update selected tab index
              });
            },
            tabs: [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.business_sharp, text: 'My Shop'),
              GButton(icon: Icons.shopping_cart_outlined, text: 'Cart'),
              GButton(icon: Icons.favorite_border, text: 'Favourite'),
              GButton(icon: Icons.person_3_outlined, text: 'Account'),
            ],
          ),
        ),
      ),
    );
  }
}
