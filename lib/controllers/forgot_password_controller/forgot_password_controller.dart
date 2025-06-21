// controllers/forgot_password_controller/forgot_password_controller.dart
import 'dart:async'; // Import for Timer
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:poketstore/model/forgot_password_model/forgot_password_model.dart';
import 'package:poketstore/service/forgot_password_service/forgot_password_service.dart';

enum ForgotPasswordStep { emailInput, otpVerification, passwordReset }

class ForgotPasswordController extends ChangeNotifier {
  final ForgotPasswordService _service = ForgotPasswordService();

  ForgotPasswordStep _currentStep = ForgotPasswordStep.emailInput;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String _email = ''; // Store email across steps
  String _otp = ''; // Store OTP for reset step

  // Timer properties
  Timer? _timer;
  int _countdownSeconds = 300; // 5 minutes in seconds
  bool _canResendOtp = false;

  ForgotPasswordStep get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get email => _email;
  String get otp => _otp;

  int get countdownSeconds => _countdownSeconds;
  bool get canResendOtp => _canResendOtp;

  // Constructor to dispose of the timer when the controller is no longer needed
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Method to update email
  void setEmail(String email) {
    _email = email;
    _errorMessage = null; // Clear error when email changes
    notifyListeners();
  }

  // Method to update OTP
  void setOtp(String otp) {
    _otp = otp;
    _errorMessage = null; // Clear error when OTP changes
    notifyListeners();
  }

  // Resets the entire flow to the initial state
  void resetFlow() {
    _currentStep = ForgotPasswordStep.emailInput;
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    _email = '';
    _otp = '';
    _timer?.cancel(); // Cancel any active timer
    _countdownSeconds = 300; // Reset countdown
    _canResendOtp = false; // Reset resend flag
    notifyListeners();
  }

  // Starts the OTP countdown timer
  void _startOtpTimer() {
    _timer?.cancel(); // Cancel any existing timer first
    _countdownSeconds = 300; // Reset to 5 minutes
    _canResendOtp = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        _countdownSeconds--;
      } else {
        _canResendOtp = true;
        _timer?.cancel();
      }
      notifyListeners();
    });
  }

  Future<void> sendOtp({bool isResend = false}) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      if (_email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_email)) {
        throw Exception('Please enter a valid email address.');
      }
      final request = SendOtpRequest(email: _email);
      final response = await _service.sendOtp(request);
      _successMessage = response.message;
      _currentStep = ForgotPasswordStep.otpVerification; // Move to next step
      _startOtpTimer(); // Start the timer after OTP is sent
      log('OTP Sent Successfully: ${_successMessage}');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      log('Send OTP Error: ${_errorMessage}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      if (_otp.isEmpty) {
        throw Exception('Please enter the OTP.');
      }
      final request = VerifyOtpRequest(email: _email, otp: _otp);
      final response = await _service.verifyOtp(request);
      _successMessage = response.message;
      _currentStep = ForgotPasswordStep.passwordReset; // Move to next step
      _timer?.cancel(); // Stop the timer once OTP is verified
      log('OTP Verified Successfully: ${_successMessage}');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      log('Verify OTP Error: ${_errorMessage}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      if (newPassword.isEmpty || newPassword.length < 6) {
        throw Exception('Password must be at least 6 characters long.');
      }
      final request = ResetPasswordRequest(
        email: _email,
        otp: _otp,
        newPassword: newPassword,
      );
      final response = await _service.resetPassword(request);
      _successMessage = response.message;
      resetFlow(); // Reset flow after successful password change
      log('Password Reset Successfully: ${_successMessage}');
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      log('Reset Password Error: ${_errorMessage}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
