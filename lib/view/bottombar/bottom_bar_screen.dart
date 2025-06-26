import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:poketstore/controllers/bottom_bar_controller/bottombar_controller.dart';
import 'package:poketstore/view/cart_screen/cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/view/favorite/favorite_screen.dart';
import 'package:poketstore/view/home/view/home_screen/home_screen.dart';
import 'package:poketstore/view/my_products/my_shop_screen.dart';
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
    CartScreen(),
    const FavoriteScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomBarProvider = Provider.of<BottomBarProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        if (bottomBarProvider.selectedIndex != 0) {
          bottomBarProvider.changeTab(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _screens[bottomBarProvider.selectedIndex],
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
            selectedIndex: bottomBarProvider.selectedIndex,
            onTabChange: (index) {
              bottomBarProvider.changeTab(index);
            },
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.business_sharp, text: 'My Shop'),
              GButton(icon: Icons.shopping_cart_outlined, text: 'Cart'),
              GButton(icon: Icons.favorite_border_outlined, text: 'Favorites'),
              GButton(icon: Icons.person_3_outlined, text: 'Account'),
            ],
          ),
        ),
      ),
    );
  }
}
