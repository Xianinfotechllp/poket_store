import 'package:flutter/material.dart';
import 'package:poketstore/controllers/login_reg_controller/login_controller.dart';
import 'package:poketstore/view/bottombar/bottom_bar_screen.dart';
import 'package:poketstore/view/login/login_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateBasedOnLogin();
    });
  }

  Future<void> _navigateBasedOnLogin() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate splash delay

    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final isLoggedIn = await loginProvider.isUserLoggedIn();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isLoggedIn ? BottomBarScreen() : LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 7, 3, 201),
      body: Center(
        child: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: 'Poket',
                style: TextStyle(color: Colors.white, fontFamily: 'Aparajita'),
              ),
              TextSpan(
                text: 'Stor',
                style: TextStyle(
                  color: Color(0xFFFFEA00),
                  fontFamily: 'Aparajita',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
