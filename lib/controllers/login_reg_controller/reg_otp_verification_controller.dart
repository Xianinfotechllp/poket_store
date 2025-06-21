// // lib/controllers/login_reg_controller/otp_verification_controller.dart

// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:poketstore/service/login_reg_service.dart/reg_service.dart';
// import 'package:poketstore/view/bottombar/bottom_bar_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class OtpVerificationProvider extends ChangeNotifier {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController otpController = TextEditingController();
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   final RegistrationService _registrationService = RegistrationService();

//   // New: Validation function for OTP
//   String? validateOtp(String? value) {
//     if (value == null || value.isEmpty) {
//       return "Please enter the OTP";
//     }
//     if (value.length != 6) {
//       return "OTP must be 6 digits";
//     }
//     return null;
//   }

//   // New: Validation function for email
//   String? validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return "Please enter your Email";
//     }
//     if (!value.contains('@')) {
//       return "Email must contain '@'";
//     }
//     if (!value.endsWith('.com')) {
//       return "Email must end with '.com'";
//     }
//     return null;
//   }

//   Future<void> verifyOtp(BuildContext context) async {
//     if (!formKey.currentState!.validate()) {
//       log("Form validation failed for OTP verification");
//       return;
//     }

//     _isLoading = true;
//     notifyListeners();
//     log("Verifying OTP...");

//     try {
//       final String email = emailController.text.trim();
//       final String otp = otpController.text.trim();

//       final response = await _registrationService.verifyOtp(email, otp);

//       // Save token and userId to shared preferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('token', response.token);
//       await prefs.setString('userId', response.userId);

//       _isLoading = false;
//       notifyListeners();

//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(response.message),
//             backgroundColor: Colors.green,
//           ),
//         );

//         // Navigate to the home screen
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => BottomBarScreen()),
//         );
//       }
//       clearTextFields();
//     } catch (e) {
//       _isLoading = false;
//       notifyListeners();
//       log("OTP Verification Error: $e");
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(e.toString().replaceFirst('Exception: ', '')),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void clearTextFields() {
//     emailController.clear();
//     otpController.clear();
//   }

//   @override
//   void dispose() {
//     emailController.dispose();
//     otpController.dispose();
//     super.dispose();
//   }
// }
