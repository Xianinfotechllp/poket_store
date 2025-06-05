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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Background Image with Reduced Height
          SizedBox(
            height: 610,
            // MediaQuery.of(context).size.height *
            // 0.6, // Adjust height as needed
            width: double.infinity,
            child: Image.asset(
              'assets/splash.png', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),

          // Spacer to push content to the bottom
          const Spacer(), // Use const for Spacer if no dynamic properties

          // Bottom Container with Navigation
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Get Started Button
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Container(
                    height: 40,
                    width: 300,
                    decoration: const BoxDecoration(
                      // Added const
                      color: Color.fromARGB(255, 6, 47, 161),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: const Center(
                      // Added const
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Continue as Guest Text
                // TextButton(
                //   onPressed: () {
                //     Navigator.pushReplacement(
                //       context,
                //       MaterialPageRoute(builder: (context) => LoginScreen()),
                //     );
                //   },
                //   child: const Text(
                //     // Added const
                //     'Continue as Guest',
                //     style: TextStyle(
                //       color: Color.fromARGB(255, 6, 47, 161),
                //       fontSize: 14,
                //       decoration: TextDecoration.underline,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
