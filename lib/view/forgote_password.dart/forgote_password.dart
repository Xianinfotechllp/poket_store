import 'package:flutter/material.dart';
import 'package:poketstore/controllers/forgot_password_controller/forgot_password_controller.dart';
import 'package:poketstore/view/login/login_screen.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyOtp = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 7, 3, 201),
          ),
          onPressed: () {
            final controller = Provider.of<ForgotPasswordController>(
              context,
              listen: false,
            );
            if (controller.currentStep == ForgotPasswordStep.otpVerification ||
                controller.currentStep == ForgotPasswordStep.passwordReset) {
              controller.resetFlow(); // Reset to email input for back button
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      extendBodyBehindAppBar:
          true, // Extend body behind the transparent app bar
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0703C9), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Consumer<ForgotPasswordController>(
            builder: (context, controller, child) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        _getTitle(controller.currentStep),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _getDescription(controller.currentStep),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildStepContent(context, controller),
                      const SizedBox(height: 20),
                      if (controller.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            controller.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      if (controller.successMessage != null &&
                          controller.currentStep !=
                              ForgotPasswordStep.emailInput)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            controller.successMessage!,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Remember Password?",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              controller.resetFlow();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 7, 3, 201),
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getTitle(ForgotPasswordStep step) {
    switch (step) {
      case ForgotPasswordStep.emailInput:
        return 'Forgot Password?';
      case ForgotPasswordStep.otpVerification:
        return 'Verify OTP';
      case ForgotPasswordStep.passwordReset:
        return 'Reset Password';
    }
  }

  String _getDescription(ForgotPasswordStep step) {
    switch (step) {
      case ForgotPasswordStep.emailInput:
        return "Don't worry! It happens. Please enter the email address linked with your account to reset your password.";
      case ForgotPasswordStep.otpVerification:
        return "Please enter the 6-digit code sent to ${Provider.of<ForgotPasswordController>(context, listen: false).email}.";
      case ForgotPasswordStep.passwordReset:
        return "Enter your new password. Make sure it's strong and easy to remember.";
    }
  }

  Widget _buildStepContent(
    BuildContext context,
    ForgotPasswordController controller,
  ) {
    switch (controller.currentStep) {
      case ForgotPasswordStep.emailInput:
        return Form(
          key: _formKeyEmail,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _getInputDecoration(
                  "Enter your email",
                  Icons.email,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onChanged: (value) => controller.setEmail(value),
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                context,
                'Send Code',
                controller.isLoading,
                () async {
                  if (_formKeyEmail.currentState!.validate()) {
                    await controller.sendOtp();
                    if (controller.successMessage != null &&
                        controller.errorMessage == null) {
                      _showSnackBar(
                        context,
                        controller.successMessage!,
                        Colors.green,
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      case ForgotPasswordStep.otpVerification:
        return Form(
          key: _formKeyOtp,
          child: Column(
            children: [
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: _getInputDecoration("Enter OTP", Icons.vpn_key),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP';
                  }
                  if (value.length != 6 ||
                      !RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'OTP must be 6 digits';
                  }
                  return null;
                },
                onChanged: (value) => controller.setOtp(value),
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                context,
                'Verify OTP',
                controller.isLoading,
                () async {
                  if (_formKeyOtp.currentState!.validate()) {
                    await controller.verifyOtp();
                    if (controller.successMessage != null &&
                        controller.errorMessage == null) {
                      _showSnackBar(
                        context,
                        controller.successMessage!,
                        Colors.green,
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 20), // Spacing for timer/resend
              controller.canResendOtp
                  ? TextButton(
                    onPressed:
                        controller.isLoading
                            ? null
                            : () {
                              controller.sendOtp(
                                isResend: true,
                              ); // Call sendOtp again
                              _showSnackBar(
                                context,
                                'OTP resent!',
                                Colors.blue,
                              );
                            },
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(
                        color:
                            controller.isLoading
                                ? Colors.grey
                                : const Color.fromARGB(255, 7, 3, 201),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  : Text(
                    'Resend code in ${(_formatDuration(controller.countdownSeconds))}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
            ],
          ),
        );
      case ForgotPasswordStep.passwordReset:
        return Form(
          key: _formKeyPassword,
          child: Column(
            children: [
              TextFormField(
                controller: _newPasswordController,
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: _getInputDecoration(
                  "Enter new password",
                  Icons.lock,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                context,
                'Reset Password',
                controller.isLoading,
                () async {
                  if (_formKeyPassword.currentState!.validate()) {
                    await controller.resetPassword(_newPasswordController.text);
                    if (controller.successMessage != null &&
                        controller.errorMessage == null) {
                      _showSnackBar(
                        context,
                        controller.successMessage!,
                        Colors.green,
                      );
                      _newPasswordController.clear();
                      // --- Navigation to LoginScreen after 2 seconds ---
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pop(context);
                      });
                    }
                  }
                },
              ),
            ],
          ),
        );
    }
  }

  InputDecoration _getInputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 7, 3, 201),
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.black),
      hintStyle: TextStyle(color: Colors.grey[500]),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    bool isLoading,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isLoading ? Colors.grey : const Color.fromARGB(255, 7, 3, 201),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 7, 3, 201).withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child:
              isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  // Helper to format duration into MM:SS
  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }
}
