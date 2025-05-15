import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:poketstore/controllers/bottom_bar_controller/bottombar_controller.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/view/cart/cart_screen.dart';
import 'package:poketstore/view/favourite/favourite_screen.dart';
import 'package:poketstore/view/home/view/home_screen/home_screen.dart';
import 'package:poketstore/view/my_shop/my_shop_screen.dart';
import 'package:poketstore/view/profile/profile_screen.dart';

class BottomBarScreen extends StatelessWidget {
  const BottomBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomBarProvider = Provider.of<BottomBarProvider>(context);

    final List<Widget> screens = [
      HomeScreen(),
      MyShopScreen(),
      CartScreen(),
      FavouriteScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: bottomBarProvider.selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: GNav(
            backgroundColor: Colors.white,
            color: Colors.black,
            activeColor: Colors.white,
            gap: 8,
            tabBackgroundColor: const Color.fromARGB(255, 7, 3, 201),
            padding: const EdgeInsets.all(10),
            selectedIndex: bottomBarProvider.selectedIndex, // Use Provider
            onTabChange: (index) {
              bottomBarProvider.changeTab(index); // Update using Provider
            },
            tabs: const [
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
