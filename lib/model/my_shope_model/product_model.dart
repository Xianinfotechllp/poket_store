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
  final String userId; // Add userId
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
    required this.userId, // Include userId properly
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? "",
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      price: int.tryParse(json['price'].toString()) ?? 0, // Ensure it's an int
      quantity: int.tryParse(json['quantity'].toString()) ?? 0, // Ensure it's an int
      category: (json['category'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      productImage: json['productImage'] ?? "https://pixabay.com/photos/himeji-castle-himeji-castle-japan-9500850/",
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
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'category': category,
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
