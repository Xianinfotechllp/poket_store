class Product {
  final String id;
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
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.category,
    required this.productImage,
    required this.sold,
    required this.estimatedTime,
    required this.productType,
    required this.deliveryOption,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? "",
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      price: json['price'] ?? "",
      quantity: json['quantity'] ?? "",
      category:
          (json['category'] as List<dynamic>).map((e) => e.toString()).toList(),
      productImage: json['productImage'] ?? "",
      sold: json['sold'] ?? 0,
      estimatedTime: json['estimatedTime'] ?? "",
      productType: json['productType'] ?? "",
      deliveryOption: json['deliveryOption'] ?? "",
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'category': category, // List<String> stays the same
      'productImage': productImage,
      'sold': sold,
      'estimatedTime': estimatedTime,
      'productType': productType,
      'deliveryOption': deliveryOption,
      'createdAt': createdAt.toIso8601String(), // Convert DateTime to String
      'updatedAt': updatedAt.toIso8601String(), // Convert DateTime to String
    };
  }
}
