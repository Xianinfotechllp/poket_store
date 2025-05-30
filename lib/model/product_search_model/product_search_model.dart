// poketstore/model/product_search_model/product_search_model.dart
import 'dart:convert';

// Define the ProductSearchModel to represent a single product in search results.
class ProductSearchModel {
  final String id;
  final String shop;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String productImage;
  final int sold;
  final String estimatedTime;
  final String productType;
  final String deliveryOption;
  final String userId;
  final bool favorite;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  ProductSearchModel({
    required this.id,
    required this.shop,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.productImage,
    required this.sold,
    required this.estimatedTime,
    required this.productType,
    required this.deliveryOption,
    required this.userId,
    required this.favorite,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  // Factory constructor to create a ProductSearchModel from a JSON map.
  factory ProductSearchModel.fromJson(Map<String, dynamic> json) {
    return ProductSearchModel(
      id: json['_id'] as String,
      shop: json['shop'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(), // Ensure price is a double
      quantity: json['quantity'] as int,
      productImage: json['productImage'] as String,
      sold: json['sold'] as int,
      estimatedTime: json['estimatedTime'] as String,
      productType: json['productType'] as String,
      deliveryOption: json['deliveryOption'] as String,
      userId: json['userId'] as String,
      favorite: json['favorite'] as bool,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      v: json['__v'] as int,
    );
  }

  // Method to convert a ProductSearchModel to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'shop': shop,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'productImage': productImage,
      'sold': sold,
      'estimatedTime': estimatedTime,
      'productType': productType,
      'deliveryOption': deliveryOption,
      'userId': userId,
      'favorite': favorite,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}
