class Product {
  final String id;
  final String? shop;
  final String name;
  final String description;
  final int price;
  final int quantity;
  final List<String> category;
  final String productImage;
  final int sold;
  final String estimatedTime;
  final String productType;
  final String deliveryOption;
  // final int totalAmount;
  final String userId; // Add userId
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    this.shop,
    required this.id,
    required this.name,
    // required this.totalAmount,
    required this.description,
    required this.price,
    required this.quantity,
    required this.category,
    required this.productImage,
    required this.sold,
    required this.estimatedTime,
    required this.productType,
    required this.deliveryOption,
    required this.userId, // Include userId properly
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse the category string back into a list
    List<String> parsedCategory = [];
    if (json['category'] != null && json['category'] is String) {
      parsedCategory = (json['category'] as String).split(',');
    } else if (json['category'] != null && json['category'] is List) {
      parsedCategory = List<String>.from(json['category']);
    }

    return Product(
      shop: json['shop'] ?? "",
      // totalAmount: json['totalAmount'],
      id: json['_id'] ?? "",
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      price: int.tryParse(json['price'].toString()) ?? 0, // Ensure it's an int
      quantity:
          int.tryParse(json['quantity'].toString()) ?? 0, // Ensure it's an int
      category: parsedCategory,
      productImage: json['productImage'] ??
          "https://pixabay.com/photos/himeji-castle-himeji-castle-japan-9500850/",
      sold: json['sold'] ?? 0,
      estimatedTime: json['estimatedTime'] ?? "",
      productType: json['productType'] ?? "",
      deliveryOption: json['deliveryOption'] ?? "",
      userId: json['userId'] ?? "", // Ensure userId is properly assigned
      createdAt: DateTime.tryParse(json['createdAt'] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? "") ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    // Convert the category list to a comma-separated string for sending to the server
    // String categoryString = category.join(',');
    return {
      'shop': shop,
      '_id': id,
      'name': name,
      'description': description,
      // 'totalAmount': totalAmount,
      'price': price,
      'quantity': quantity,
      'category': category, // Use the string here
      'productImage': productImage,
      'sold': sold,
      'estimatedTime': estimatedTime,
      'productType': productType,
      'deliveryOption': deliveryOption,
      'userId': userId, // Include userId in toJson
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
