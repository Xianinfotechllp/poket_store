class CartItem {
  final String productId;
  final int quantity;
  final String? id;

  CartItem({required this.productId, required this.quantity, this.id});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      quantity: json['quantity'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {"productId": productId, "quantity": quantity};
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
      items:
          (json['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList(),
      id: json['_id'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
