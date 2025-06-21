// lib/view/subscription/subscription.dart (No changes needed here for the requested functionality)

import 'package:flutter/material.dart';
import 'package:poketstore/controllers/subscription_controller/subscription_controller.dart';
import 'package:poketstore/model/subscription_model/subscription_model.dart';
import 'package:provider/provider.dart';

class Subscription extends StatefulWidget {
  const Subscription({super.key});

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  @override
  void initState() {
    super.initState();
    // Fetch subscription plans when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubscriptionProvider>(
        context,
        listen: false,
      ).fetchSubscriptionPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Subscription',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 7, 3, 201),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.plans.isEmpty) {
            // Show loading indicator only when initially fetching and no plans are loaded
            return const Center(child: CircularProgressIndicator());
          } else if (provider.errorMessage != null) {
            // Show error message if an error occurred
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${provider.errorMessage}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          } else if (provider.plans.isEmpty) {
            // Show message if no plans are available after loading
            return const Center(
              child: Text(
                'No subscription plans available at the moment.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          } else {
            // Display fetched plans
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Choose Your Plan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ...provider.plans.map((plan) {
                  // Dynamically assign colors based on plan index or type
                  Color color1;
                  Color color2;
                  if (plan.durationDays == 30) {
                    color1 = Colors.blue.shade400;
                    color2 = Colors.blue.shade600;
                  } else if (plan.durationDays == 365) {
                    color1 = Colors.indigo.shade400;
                    color2 = Colors.indigo.shade600;
                  } else {
                    // Default colors for other plans
                    color1 = Colors.deepPurple.shade400;
                    color2 = Colors.deepPurple.shade600;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildSubscriptionCard(
                      context,
                      provider: provider, // Pass provider to card for action
                      plan: plan,
                      color1: color1,
                      color2: color2,
                    ),
                  );
                }).toList(),
              ],
            );
          }
        },
      ),
    );
  }

  // Modified to accept SubscriptionPlan and provider
  Widget _buildSubscriptionCard(
    BuildContext context, {
    required SubscriptionProvider provider, // Added provider
    required SubscriptionPlan plan, // Changed to SubscriptionPlan object
    required Color color1,
    required Color color2,
  }) {
    // Check if this specific plan is currently being subscribed to
    final bool isSubscribingThisPlan =
        provider.currentlySubscribingPlanId == plan.id;
    // Check if this specific plan is already subscribed
    final bool isSubscribed = provider.isSubscribed(plan.id);

    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color2.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Icon based on duration or a generic one
          Icon(
            plan.durationDays == 30
                ? Icons.calendar_today
                : Icons.calendar_view_month,
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name, // Use plan name
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${plan.amount}/${plan.durationDays == 30
                      ? 'month'
                      : plan.durationDays == 365
                      ? 'year'
                      : '${plan.durationDays} days'}', // Dynamic price
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            // Disable button if this plan is being subscribed or already subscribed
            onPressed:
                isSubscribingThisPlan || isSubscribed
                    ? null // Disable button
                    : () {
                      provider.initiateSubscription(context, plan);
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: color2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child:
                isSubscribingThisPlan
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                        strokeWidth: 2,
                      ),
                    ) // Show specific loading indicator for this plan
                    : isSubscribed
                    ? const Text('Subscribed') // Show "Subscribed" text
                    : const Text('Subscribe'), // Default "Subscribe" text
          ),
        ],
      ),
    );
  }
}
