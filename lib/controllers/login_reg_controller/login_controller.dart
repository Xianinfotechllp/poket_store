import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/login_reg_model/login_model.dart';
import 'package:poketstore/service/login_reg_service.dart/login_service.dart';
import 'package:poketstore/view/bottombar/bottom_bar_screen.dart';
import 'package:poketstore/view/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginProvider extends ChangeNotifier {
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoading => _isLoading;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  /// **Login User and Store Details in SharedPreferences**
  Future<void> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    _isLoading = true;
    notifyListeners();

    try {
      final loginService = LoginService();
      log(
        "Attempting login with mobileNumber: ${mobileNumberController.text.trim()}",
      );

      final response = await loginService.loginUser(
        mobileNumberController.text.trim(),
        passwordController.text.trim(),
      );

      log("Login Response: $response");

      final loginModel = LoginModel.fromJson(response);

      // Store login details in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', loginModel.token);
      await prefs.setString('userId', loginModel.user.id);
      await prefs.setString('mobileNumber', mobileNumberController.text.trim());
      await prefs.setString('password', passwordController.text.trim());

      _isLoading = false;
      notifyListeners();

      log("Login successful, details stored.");

      // Navigate to Home Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomBarScreen()),
      );

      // Show success snackbar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login successful!")));
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      log("Login Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed. Please try again.")),
      );
    }
  }

  /// **Check if User is Already Logged In**
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null; // If token exists, user is logged in
  }

  /// **Logout Function (Call this only when the user logs out manually)**
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Clears all stored data
    notifyListeners();

    log("User logged out manually.");

    // Navigate back to login screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SplashScreen()),
      (route) => false, // Clear navigation stack
    );
  }
}
