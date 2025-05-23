import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:poketstore/controllers/bottom_bar_controller/bottombar_controller.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/view/favorite/favorite_screen.dart';
import 'package:poketstore/view/home/view/home_screen/home_screen.dart';
import 'package:poketstore/view/my_shop/my_shop_screen.dart';
import 'package:poketstore/view/profile/profile_screen.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  _BottomBarScreenState createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const MyShopScreen(),
    const FavoriteScreen(),
    // const FavouriteScreen(), // Removed from original code
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomBarProvider = Provider.of<BottomBarProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        // If the current tab is not the home tab, navigate to the home tab.
        if (bottomBarProvider.selectedIndex != 0) {
          bottomBarProvider.changeTab(0); // Use the provider to change the tab
          return false; // Prevent the default back button behavior (exiting the app).
        }
        // If the current tab is the home tab, allow the default back button behavior.
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: bottomBarProvider.selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
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
              GButton(icon: Icons.favorite_border_outlined, text: 'Favorites'),
              // GButton(icon: Icons.favorite_border, text: 'Favourite'), // Removed from original code
              GButton(icon: Icons.person_3_outlined, text: 'Account'),
            ],
          ),
        ),
      ),
    );
  }
}
