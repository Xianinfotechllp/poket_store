class CartItem {
  final String? productId;
  final String? name;
  final int? price;
  final String? productImage;
  final int? quantity;
  final int? totalAmount;
  final String? id;

  CartItem({
    this.productId,
    this.name,
    this.price,
    this.productImage,
    this.quantity,
    this.totalAmount,
    this.id,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json['productId'];

    return CartItem(
      productId: product is String ? product : product['_id'],
      name: product is Map ? product['name'] : null,
      price: product is Map ? product['price'] : null,
      productImage: product is Map ? product['productImage'] : null,
      quantity: json['quantity'],
      totalAmount: json['totalAmount'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "quantity": quantity,
      "totalAmount": totalAmount,
    };
  }
}

class Cart {
  final String userId;
  final List<CartItem> items;
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cart({
    required this.userId,
    required this.items,
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      userId: json['userId'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      id: json['_id'],
      createdAt:
      json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
      json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "items": items.map((item) => item.toJson()).toList(),
      "_id": id,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }
}
