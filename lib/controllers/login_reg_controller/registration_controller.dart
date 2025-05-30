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
  final TextEditingController localityController =
      TextEditingController(); // Added locality controller
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final RegistrationService _registrationService = RegistrationService();

  // Validation function for password confirmation
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }
    if (value != passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  register(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      log("Form validation failed");
      return;
    }

    _isLoading = true;
    notifyListeners();
    log("Registering user...");

    try {
      final Map<String, dynamic> userData = {
        "name": nameController.text.trim(),
        "mobileNumber": mobileController.text.trim(),
        "state": stateController.text.trim(),
        "place": placeController.text.trim(),
        "pincode": pincodeController.text.trim(),
        "locality": localityController.text
            .trim(), // Include locality in user data.  IMPORTANT
        "password": passwordController.text.trim(),
      };

      final RegistrationModel registeredUser =
          await _registrationService.registerUser(userData);

      log("Registration successful: ${registeredUser.toJson()}"); // Log the user data

      await _saveUserData(registeredUser);

      _isLoading = false;
      notifyListeners();

      // Show success snackbar
      if (context.mounted) {
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
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      log("Registration Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration failed. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    await prefs.setString('locality', user.locality); // Save locality
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    stateController.dispose();
    placeController.dispose();
    pincodeController.dispose();
    passwordController.dispose();
    localityController.dispose(); // Dispose locality controller
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Function to clear all text fields
  void clearTextFields() {
    nameController.clear();
    mobileController.clear();
    stateController.clear();
    placeController.clear();
    localityController.clear();
    pincodeController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }
}
