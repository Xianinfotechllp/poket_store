// lib/model/subscription/subscription_model.dart

/// Represents a single subscription plan retrieved from the API.
class SubscriptionPlan {
  final String id;
  final String name;
  final int durationDays;
  final int amount;
  final String description;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.amount,
    required this.description,
  });

  /// Factory constructor to create a [SubscriptionPlan] from a JSON map.
  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['_id'] ?? '', // MongoDB's default ID field
      name: json['name'] ?? '',
      durationDays: json['durationDays'] ?? 0,
      amount: json['amount'] ?? 0,
      description: json['description'] ?? '',
    );
  }

  /// Converts this [SubscriptionPlan] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'durationDays': durationDays,
      'amount': amount,
      'description': description,
    };
  }
}

/// Represents the detailed information of an active or newly created subscription.
/// This model will be used for the 'subscription' object within the StartSubscriptionResponse.
class SubscriptionDetails {
  final String id;
  final String userId;
  final int durationDays;
  final int amount;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String paymentStatus;

  SubscriptionDetails({
    required this.id,
    required this.userId,
    required this.durationDays,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.paymentStatus,
  });

  /// Factory constructor to create a [SubscriptionDetails] from a JSON map.
  factory SubscriptionDetails.fromJson(Map<String, dynamic> json) {
    return SubscriptionDetails(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      durationDays: json['durationDays'] ?? 0,
      amount: json['amount'] ?? 0,
      // Parse ISO 8601 strings to DateTime objects
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime(0),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime(0),
      status: json['status'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
    );
  }

  /// Converts this [SubscriptionDetails] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'durationDays': durationDays,
      'amount': amount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'paymentStatus': paymentStatus,
    };
  }
}

/// Represents the response received after attempting to start a subscription.
/// Now includes the nested 'subscription' details.
class StartSubscriptionResponse {
  final bool success;
  final String? message; // Optional message from the backend
  final SubscriptionDetails?
  subscription; // New: Details of the subscribed plan

  StartSubscriptionResponse({
    required this.success,
    this.message,
    this.subscription,
  });

  /// Factory constructor to create a [StartSubscriptionResponse] from a JSON map.
  factory StartSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return StartSubscriptionResponse(
      success: json['success'] ?? false,
      message: json['message'],
      // Conditionally parse the 'subscription' object if it exists
      subscription:
          json['subscription'] != null
              ? SubscriptionDetails.fromJson(json['subscription'])
              : null,
    );
  }

  /// Converts this [StartSubscriptionResponse] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'subscription':
          subscription?.toJson(), // Convert subscription details to JSON
    };
  }
}
