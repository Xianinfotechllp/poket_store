import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/login_reg_model/reg_model.dart';
import 'package:poketstore/service/login_reg_service.dart/reg_service.dart';
import 'package:poketstore/view/bottombar/bottom_bar_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationProvider extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final RegistrationService _registrationService = RegistrationService();

  Future<void> register(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> userData = {
        "name": nameController.text.trim(),
        "mobileNumber": mobileController.text.trim(),
        "state": stateController.text.trim(),
        "place": placeController.text.trim(),
        "pincode": pincodeController.text.trim(),
        "password": passwordController.text.trim(),
      };

      final RegistrationModel registeredUser = await _registrationService
          .registerUser(userData);

      // Log the full response
      // log("Registration Successful: ${registeredUser.()}");

      await _saveUserData(registeredUser);

      _isLoading = false;
      notifyListeners();

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Registration successful! Welcome, ${registeredUser.name}.",
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to the home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomBarScreen()),
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      log("Registration Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration failed. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveUserData(RegistrationModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', user.token);
    await prefs.setString('userId', user.id);
    await prefs.setString('name', user.name);
    await prefs.setString('mobileNumber', user.mobileNumber);
    await prefs.setString('state', user.state);
    await prefs.setString('place', user.place);
    await prefs.setString('pincode', user.pincode);
  }
}
