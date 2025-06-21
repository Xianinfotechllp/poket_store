// lib/services/subscription/subscription_service.dart

import 'dart:convert';
import 'dart:developer'; // For logging
import 'package:dio/dio.dart';
import 'package:poketstore/model/subscription_model/subscription_model.dart'; // Import the models

class SubscriptionService {
  final Dio _dio = Dio(); // Dio instance for HTTP requests

  // API endpoints
  final String _getAllPlansUrl =
      "https://shop-app-backend-gsx6.onrender.com/api/subscription-plans/getallplan";
  final String _startSubscriptionUrl =
      "https://shop-app-backend-gsx6.onrender.com/api/subscription/start-subscription";
  // Assuming this is your endpoint to get the current user's subscription
  final String _getCurrentSubscriptionUrl =
      "https://shop-app-backend-gsx6.onrender.com/api/subscription/current";

  /// Fetches all available subscription plans from the API.
  /// Returns a list of [SubscriptionPlan] on success.
  /// Throws an [Exception] on failure.
  Future<List<SubscriptionPlan>> getAllSubscriptionPlans() async {
    try {
      log("Fetching all subscription plans from: $_getAllPlansUrl");
      Response response = await _dio.get(_getAllPlansUrl);

      log("Get All Plans Response Status: ${response.statusCode}");
      log("Get All Plans Response Data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> plansJson = response.data['plans'];
        return plansJson
            .map(
              (json) => SubscriptionPlan.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        log("Failed to fetch subscription plans: ${response.data}");
        throw Exception(
          "Failed to load subscription plans: ${response.data['message'] ?? 'Unknown error'}",
        );
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors (network, timeouts, bad response)
      log("DioError during getAllSubscriptionPlans: ${e.message}");
      if (e.response != null) {
        log("DioError Response Data: ${e.response?.data}");
        throw Exception(
          "Network error: ${e.response?.data['message'] ?? e.message}",
        );
      } else {
        throw Exception("Network error: ${e.message}");
      }
    } catch (e) {
      log("General error during getAllSubscriptionPlans: $e");
      throw Exception("An unexpected error occurred: $e");
    }
  }

  /// Initiates a new subscription for a user.
  /// Requires the user's authentication token, duration, and amount.
  /// Returns a [StartSubscriptionResponse] on success.
  /// Throws an [Exception] on failure.
  Future<StartSubscriptionResponse> startSubscription({
    required String token, // Assuming token is needed for authorization
    required String durationDays,
    required String amount,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        "durationDays": int.parse(durationDays), // Ensure these are ints
        "amount": int.parse(amount), // Ensure these are ints
      };

      log(
        "Starting subscription with data: $requestBody to $_startSubscriptionUrl",
      );

      Response response = await _dio.post(
        _startSubscriptionUrl,
        data: jsonEncode(requestBody), // Encode body to JSON string
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token', // Pass the auth token
          },
        ),
      );

      log("Start Subscription Response Status: ${response.statusCode}");
      log("Start Subscription Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return StartSubscriptionResponse.fromJson(response.data);
        } else {
          // If the backend sends a plain string success message or unexpected format
          // This case might need adjustment if your backend is consistent.
          return StartSubscriptionResponse(
            success: true,
            message: response.data.toString(),
            subscription:
                null, // No subscription details if not in expected format
          );
        }
      } else {
        log("Failed to start subscription: ${response.data}");
        throw Exception(
          "Failed to start subscription: ${response.data['message'] ?? 'Unknown error'}",
        );
      }
    } on DioException catch (e) {
      log("DioError during startSubscription: ${e.message}");
      if (e.response != null) {
        log("DioError Response Data: ${e.response?.data}");
        // Return a StartSubscriptionResponse with success: false for API-level errors
        return StartSubscriptionResponse(
          success: false,
          message: e.response?.data['message'] ?? e.message,
        );
      } else {
        throw Exception("Network error: ${e.message}");
      }
    } catch (e) {
      log("General error during startSubscription: $e");
      throw Exception("An unexpected error occurred: $e");
    }
  }

  /// Fetches the current user's active subscription status.
  /// Returns a [SubscriptionDetails] object if an active subscription is found,
  /// otherwise returns null.
  /// Throws an [Exception] on network or API errors.
  Future<SubscriptionDetails?> getCurrentSubscriptionStatus({
    required String token,
  }) async {
    try {
      log(
        "Fetching current subscription status from: $_getCurrentSubscriptionUrl",
      );
      Response response = await _dio.get(
        _getCurrentSubscriptionUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      log("Get Current Subscription Response Status: ${response.statusCode}");
      log("Get Current Subscription Response Data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (response.data['subscription'] != null) {
          return SubscriptionDetails.fromJson(
            response.data['subscription'] as Map<String, dynamic>,
          );
        } else {
          // Backend indicates success but no active subscription found (e.g., subscription: null)
          log(
            "Backend reported success, but no active subscription found in 'subscription' field.",
          );
          return null;
        }
      } else if (response.statusCode == 404 || response.statusCode == 204) {
        // Common status codes for "no content" or "not found"
        log("No active subscription found (Status: ${response.statusCode}).");
        return null;
      } else {
        log("Failed to get current subscription status: ${response.data}");
        throw Exception(
          "Failed to get current subscription status: ${response.data['message'] ?? 'Unknown error'}",
        );
      }
    } on DioException catch (e) {
      log("DioError during getCurrentSubscriptionStatus: ${e.message}");
      if (e.response != null) {
        log("DioError Response Data: ${e.response?.data}");
        // If the error indicates no active subscription (e.g., 404), return null
        if (e.response?.statusCode == 404 || e.response?.statusCode == 204) {
          return null;
        }
        throw Exception(
          "Network error: ${e.response?.data['message'] ?? e.message}",
        );
      } else {
        throw Exception("Network error: ${e.message}");
      }
    } catch (e) {
      log("General error during getCurrentSubscriptionStatus: $e");
      throw Exception("An unexpected error occurred: $e");
    }
  }
}
