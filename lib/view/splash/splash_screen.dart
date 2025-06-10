import 'package:flutter/material.dart';
import 'package:poketstore/controllers/login_reg_controller/login_controller.dart';
import 'package:poketstore/view/bottombar/bottom_bar_screen.dart';
import 'package:poketstore/view/login/login_screen.dart';
import 'package:poketstore/view/set_location/set_location.dart'; // This import might not be used, but keeping it as per original.
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _checkLoginStatus();
      },
    );
  }

  Future<void> _checkLoginStatus() async {
    // Ensure the widget is still mounted before performing navigation
    try {
      if (!mounted) return;

      final loginProvider = Provider.of<LoginProvider>(context, listen: false);
      final isLoggedIn = await loginProvider.isUserLoggedIn();

      if (!mounted) return; // Check again after async operation

      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomBarScreen()),
        );
      } else {
        // Corrected: Navigate to LoginScreen if not logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 7, 3, 201),
      body: Center(
          child: RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: 'poket',
              style: TextStyle(color: Colors.white, fontFamily: 'Aparajita'),
            ),
            TextSpan(
              text: 'stor',
              style:
                  TextStyle(color: Color(0xFFFFEA00), fontFamily: 'Aparajita'),
            ),
          ],
        ),
      )),
    );
  }
}
