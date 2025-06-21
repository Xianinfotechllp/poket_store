// lib/controllers/subscription/subscription_provider.dart

import 'dart:developer'; // For logging
import 'package:flutter/material.dart';
import 'package:poketstore/model/subscription_model/subscription_model.dart';
import 'package:poketstore/service/subscription_service/subscription_service.dart';

import 'package:shared_preferences/shared_preferences.dart'; // To retrieve stored token

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();

  // Public fields
  List<SubscriptionPlan> plans = [];
  bool isLoading = true; // CHANGED: Initialize isLoading to true
  String? errorMessage;

  // New: Field to track the ID of the plan currently being subscribed to (for loading state of a specific button)
  String? currentlySubscribingPlanId;

  // NEW: Field to store the ID of the user's active subscription plan
  String?
  activeSubscriptionPlanId; // This will hold the ID of the active plan's plan ID

  /// New: Method to check if a plan is subscribed
  bool isSubscribed(String planId) {
    // A plan is "subscribed" if its ID matches the active subscription plan ID
    return activeSubscriptionPlanId == planId;
  }

  /// Fetches all subscription plans and updates the state.
  /// Handles loading, success, and error states.
  Future<void> fetchSubscriptionPlans() async {
    isLoading = true; // Keep this here to reset loading state for re-fetches
    errorMessage = null; // Clear previous errors
    notifyListeners();

    try {
      plans = await _subscriptionService.getAllSubscriptionPlans();
      log("Successfully fetched ${plans.length} subscription plans.");

      // After fetching plans, also fetch the user's active subscription
      await fetchUserActiveSubscription();
    } catch (e) {
      errorMessage = e.toString();
      log("Error fetching subscription plans: $errorMessage");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// NEW: Fetches the current user's active subscription and updates activeSubscriptionPlanId.
  Future<void> fetchUserActiveSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        log(
          "No token found for fetching active subscription. User might not be logged in.",
        );
        activeSubscriptionPlanId =
            null; // Ensure no active plan is set if no token
        return;
      }

      final SubscriptionDetails? activeSubscription = await _subscriptionService
          .getCurrentSubscriptionStatus(token: token);

      if (activeSubscription != null) {
        activeSubscriptionPlanId = activeSubscription.id;
        log(
          "User has active subscription with plan ID: $activeSubscriptionPlanId. Status: ${activeSubscription.status}",
        );
      } else {
        activeSubscriptionPlanId = null;
        log("No active subscription found for user.");
      }
    } catch (e) {
      log("Error fetching user active subscription: $e");
      activeSubscriptionPlanId = null; // Clear if error
    } finally {
      // notifyListeners() is called in the `finally` block of `fetchSubscriptionPlans`
      // This ensures all state updates (plans and active subscription) are notified together.
    }
  }

  /// Initiates a subscription for a given plan.
  /// Requires BuildContext for SnackBar.
  /// Returns true if subscription was successful, false otherwise.
  Future<bool> initiateSubscription(
    BuildContext context,
    SubscriptionPlan selectedPlan,
  ) async {
    currentlySubscribingPlanId = selectedPlan.id;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      log("Retrieved token for subscription: $token");

      if (token == null || token.isEmpty) {
        errorMessage = "User not authenticated. Please log in.";
        log("Error: $errorMessage");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage!), backgroundColor: Colors.red),
          );
        }
        return false;
      }

      final String durationDays = selectedPlan.durationDays.toString();
      final String amount = selectedPlan.amount.toString();

      final StartSubscriptionResponse response = await _subscriptionService
          .startSubscription(
            token: token,
            durationDays: durationDays,
            amount: amount,
          );

      if (response.success) {
        log("Subscription initiated successfully: ${response.message}");
        if (response.subscription != null &&
            response.subscription!.status == 'active') {
          activeSubscriptionPlanId = response.subscription!.id;
          log(
            "Active subscription plan ID updated to: ${activeSubscriptionPlanId}",
          );
        } else {
          await fetchUserActiveSubscription();
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? "Subscription successful!"),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } else {
        errorMessage = response.message ?? "Subscription failed.";
        log("Subscription initiation failed: $errorMessage");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage!), backgroundColor: Colors.red),
          );
        }
        return false;
      }
    } catch (e) {
      errorMessage = "Failed to initiate subscription: ${e.toString()}";
      log("Catch error initiating subscription: $errorMessage");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage!), backgroundColor: Colors.red),
        );
      }
      return false;
    } finally {
      currentlySubscribingPlanId = null;
      isLoading = false;
      notifyListeners();
    }
  }
}
