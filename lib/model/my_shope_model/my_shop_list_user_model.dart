class MyShopListUserResponse {
  final String message;
  final List<ShopData> data;

  MyShopListUserResponse({required this.message, required this.data});

  factory MyShopListUserResponse.fromJson(Map<String, dynamic> json) {
    return MyShopListUserResponse(
      message: json['message'],
      data:
          (json['data'] as List?)?.map((e) => ShopData.fromJson(e)).toList() ??
              [],
    );
  }
}

class ShopData {
  final String shopName;
  final List<Product> products;

  ShopData({required this.shopName, required this.products});

  factory ShopData.fromJson(Map<String, dynamic> json) {
    return ShopData(
      shopName: json['shopName'],
      products: (json['products'] as List?)
              ?.map((e) => Product.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Product {
  final String id;
  final String shop;
  final String name;
  final int? price;
  final int? quantity;
  final List<String>? category;
  final String? productImage;
  final int? sold;
  final String? productType;
  final String? deliveryOption;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String? description;

  Product({
    required this.id,
    required this.shop,
    required this.name,
    this.price,
    this.quantity,
    this.category,
    this.productImage,
    this.sold,
    this.productType,
    this.deliveryOption,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      shop: json['shop'] ?? '',
      name: json['name'] ?? '',
      price: json['price'],
      quantity: json['quantity'],
      category: (json['category'] as List?)?.map((e) => e.toString()).toList(),
      productImage: json['productImage'],
      sold: json['sold'],
      productType: json['productType'],
      deliveryOption: json['deliveryOption'],
      userId: json['userId'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'],
      description: json['description'],
    );
  }
}
